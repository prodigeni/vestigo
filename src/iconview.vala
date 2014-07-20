namespace Vestigo
{
  public class IconView : GLib.Object
  {
    Gtk.TreeIter iter;
    string content;
    Gee.ArrayList<string> history = new Gee.ArrayList<string>();

    public void open_location(GLib.File file, bool start_monitor)
    {
      var list_dir  = new Gee.ArrayList<string>();
      var list_file = new Gee.ArrayList<string>();

      string name;
      string fullpath;
      current_dir = file.get_path();
      Gdk.Pixbuf pbuf = null;
      
      history.add(current_dir);
      foreach(string i in history)
      {
        stdout.printf("%s\n", i);
      }

      if (current_dir != null && file.query_file_type(0) == GLib.FileType.DIRECTORY)
      {
        try
        {
          var d = Dir.open(file.get_path());
          model.clear();
          
          while ((name = d.read_name()) != null)
          {
            fullpath = GLib.Path.build_filename(current_dir, name);
            get_file_content(fullpath);

            if (content == "inode/directory")
              list_dir.add(name);
            else
              list_file.add(name);
          }
          
          list_dir.sort();
          list_file.sort();
          
          foreach(string i in list_dir)
          {
            fullpath = GLib.Path.build_filename(current_dir, i);
            
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
            pbuf = icon_theme.load_icon("folder", icon_size, 0);
            
            model.append(out iter);
            model.set(iter, 0, pbuf, 1, i, 2, fullpath, 3, i.replace("&", "&amp;"));
          }   
          
          foreach(string i in list_file)
          { 
            fullpath = GLib.Path.build_filename(current_dir, i);
            get_file_content(fullpath);

            GLib.Icon icon = GLib.ContentType.get_icon(content);
            Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
            Gtk.IconInfo? icon_info = icon_theme.lookup_by_gicon(icon, icon_size, 0);

            if (content == "image/jpeg" || content == "image/png")
            {
              new Vestigo.Images().get_thumbnail_from_file_name.begin(fullpath, (obj, res) =>
              {
                pbuf = new Vestigo.Images().get_thumbnail_from_file_name.end(res);
                
                model.append(out iter);
                model.set(iter, 0, pbuf, 1, i, 2, GLib.Path.build_filename(current_dir, i), 3, i.replace("&", "&amp;")); 
              });
            }
            else if (content == "application/pdf")
            {
              new Vestigo.PdfPreview().get_pdf_preview_from_file_name.begin(fullpath, (obj, res) =>
              {
                pbuf = new Vestigo.PdfPreview().get_pdf_preview_from_file_name.end(res);
                
                model.append(out iter);
                model.set(iter, 0, pbuf, 1, i, 2, GLib.Path.build_filename(current_dir, i), 3, i.replace("&", "&amp;"));
              });
            }
            else
            {
              if (icon_info != null)
                pbuf = icon_info.load_icon();
              else
                pbuf = icon_theme.load_icon("gtk-file", icon_size, 0);
                
              model.append(out iter);
              model.set(iter, 0, pbuf, 1, i, 2, fullpath, 3, i.replace("&", "&amp;"));
            }
          }
          if (start_monitor == true)
            new Vestigo.DirectoryMonitor();          
          
          headerbar.set_title("%s - %s".printf(NAME, current_dir));
          list_dir.clear();
          list_file.clear();
        }
        catch (GLib.Error e)
        {
          stderr.printf("%s\n", e.message);
        }
      }
    }

    public void icon_clicked()
    {
      List<Gtk.TreePath> paths = view.get_selected_items();
      GLib.Value filepath;
      foreach (Gtk.TreePath path in paths)
      {
        model.get_iter(out iter, path);
        model.get_value(iter, 2, out filepath);
        var file_check = File.new_for_path((string)filepath);
        if (file_check.query_file_type(0) == GLib.FileType.DIRECTORY)
        {
          open_location(GLib.File.new_for_path((string)filepath), true);
        }
        else
        {
          try
          {
            GLib.FileInfo file_info = file_check.query_info("standard::content-type", 0, null);
            string content = file_info.get_content_type();
            string mime = GLib.ContentType.get_mime_type(content);

            var appinfo = AppInfo.get_default_for_type(mime, false); 
            if (appinfo != null)
              new Vestigo.Operations().execute_command_async("%s '%s'".printf(appinfo.get_executable(), (string)filepath));
            else
            {
              var dialog = new Gtk.AppChooserDialog.for_content_type(window, 0, mime);
              if (dialog.run() == Gtk.ResponseType.OK)
              {
                appinfo = dialog.get_app_info();
                if (appinfo != null)
                  new Vestigo.Operations().execute_command_async("%s '%s'".printf(appinfo.get_executable(), (string)filepath));
              }
              dialog.close();
            }
          }
          catch (GLib.Error e)
          {
            stderr.printf ("%s\n", e.message);
          }
        }
      }
    }

    public string get_file_content(string filepath) throws GLib.Error
    {
      var file_check = File.new_for_path(filepath);
      var file_info = file_check.query_info("standard::content-type", 0, null);
      content = file_info.get_content_type();
      return content;
    }
    
    public void go_to_prev_directory()
    {
      
    }
    public void go_to_next_directory()
    {
      
    }    
    
  }
}
