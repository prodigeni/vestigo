namespace Vestigo
{
  public class Operations: GLib.Object
  {
    // Make
    public void make_new(bool file)
    {
      string entry_title = null;
      string typed = null;
      
      if (file == true)
        entry_title = _("Create File");
      else
        entry_title = _("Create Folder");
        
      var dialog = new Gtk.Dialog();
      dialog.set_title(entry_title);
      dialog.set_border_width(10);
      dialog.set_property("skip-taskbar-hint", true);
      dialog.set_transient_for(window);
      dialog.set_resizable(false);

      var entry = new Gtk.Entry();
      entry.set_size_request(190, 0);
      entry.activate.connect(() => { typed = entry.get_text(); on_make_new_dialog_response(entry, dialog, typed, file); });

      var content = dialog.get_content_area() as Gtk.Box;
      content.pack_start(entry, true, true, 10);

      dialog.add_button(_("Create"), Gtk.ResponseType.OK);
      dialog.add_button(_("Close"), Gtk.ResponseType.CLOSE);
      dialog.set_default_response(Gtk.ResponseType.OK);
      dialog.show_all();
      
      if (dialog.run() == Gtk.ResponseType.OK)
      {
        typed = entry.get_text();
        on_make_new_dialog_response(entry, dialog, typed, file);
      }
      dialog.destroy();
    }

    private void on_make_new_dialog_response(Gtk.Entry entry, Gtk.Dialog dialog, string typed, bool file)
    {
      if (typed != "")
        if (file == true)
          execute_command_sync("touch '%s'".printf(GLib.Path.build_filename(current_dir, typed)));
        else
          execute_command_sync("mkdir '%s'".printf(GLib.Path.build_filename(current_dir, typed)));
      dialog.destroy();
    }

    // Bookmark
    public void add_bookmark()
    {
      GLib.FileOutputStream fos = null;
      string bookmark = GLib.Path.build_filename(GLib.Environment.get_user_config_dir(), "gtk-3.0/bookmarks");
      try
      {
        fos = File.new_for_path(bookmark).append_to(FileCreateFlags.NONE);
      }
      catch (GLib.Error e)
      {
        stderr.printf ("%s\n", e.message);
      }
      string current_uri = GLib.File.new_for_path(current_dir).get_uri() + "\n";
      try
      {
        fos.write(current_uri.data);
      }
      catch (GLib.IOError e)
      {
        stderr.printf ("%s\n", e.message);
      }
    }

    // Cut
    public void file_cut_activate()
    {
      if (files_copy != null)
        files_copy.clear();
      files_cut = get_files_selection();
    }

    // Copy
    public void file_copy_activate()
    {
      if (files_cut!= null)
        files_cut.clear();
      files_copy = get_files_selection();
    }

    // Paste
    public void file_paste_activate()
    {
      if (files_copy != null)
      {
        foreach(string i in files_copy)
        {
          execute_command_sync("cp -a '%s' '%s'".printf(i, current_dir));
          stdout.printf("DEBUG: copying '%s' to '%s'\n".printf(i, current_dir));
        }
      }

      if (files_cut != null)
      {
        foreach(string i in files_cut)
        {
          execute_command_sync("mv '%s' '%s'".printf(i, current_dir));
          stdout.printf("DEBUG: moving '%s' to '%s'\n".printf(i, current_dir));
        }
      }
    }

    // Rename
    public void file_rename_activate()
    {
      var files_rename = new Gee.ArrayList<string>();
      files_rename = get_files_selection();
      string typed = null;

      if (files_rename.size == 1)
      {
        var dialog = new Gtk.Dialog();
        dialog.set_title(_("Rename File/Folder"));
        dialog.set_border_width(10);
        dialog.set_property("skip-taskbar-hint", true);
        dialog.set_transient_for(window);
        dialog.set_resizable(false);

        var entry = new Gtk.Entry();
        entry.set_size_request(190, 0);
        entry.set_text(GLib.Path.get_basename(files_rename[0]));
        entry.activate.connect(() => { typed = entry.get_text(); on_rename_dialog_response(entry, dialog, files_rename[0], typed); });

        var content = dialog.get_content_area() as Gtk.Box;
        content.pack_start(entry, true, true, 10);

        dialog.add_button(_("Rename"), Gtk.ResponseType.OK);
        dialog.add_button(_("Close"), Gtk.ResponseType.CLOSE);
        dialog.set_default_response(Gtk.ResponseType.OK);
        dialog.show_all();

        if (dialog.run() == Gtk.ResponseType.OK)
        {
          typed = entry.get_text();
          on_rename_dialog_response(entry, dialog, files_rename[0], typed);
        }
        dialog.destroy();
      }
    }

    private void on_rename_dialog_response(Gtk.Entry entry, Gtk.Dialog dialog, string old_path, string new_name)
    {
      if (new_name != "")
        execute_command_sync("mv '%s' '%s'".printf(old_path, GLib.Path.build_filename(current_dir, new_name)));
        stdout.printf("DEBUG: moving '%s' to '%s'\n".printf(old_path, GLib.Path.build_filename(current_dir, new_name)));
      dialog.destroy();
    }

    // Delete
    public void file_delete_activate()
    {
      var files_delete = new Gee.ArrayList<string>();
      files_delete = get_files_selection();

      var dialog = new Gtk.Dialog();
      dialog.set_title(_("Delete File/Folder"));
      dialog.set_border_width(10);
      dialog.set_property("skip-taskbar-hint", true);
      dialog.set_transient_for(window);
      dialog.set_resizable(false);

      var label = new Gtk.Label(_("Delete %d selected item(s)?").printf(files_delete.size));

      var content = dialog.get_content_area() as Gtk.Box;
      content.pack_start(label, true, true, 10);

      dialog.add_button(_("Delete"), Gtk.ResponseType.OK);
      dialog.add_button(_("Close"), Gtk.ResponseType.CLOSE);
      dialog.set_default_response(Gtk.ResponseType.OK);
      dialog.show_all();

      if (dialog.run() == Gtk.ResponseType.OK)
      {
        foreach(string i in files_delete)
        {
          on_delete_dialog_response(dialog, i);
        }
      }
      dialog.destroy();
    }

    private void on_delete_dialog_response(Gtk.Dialog dialog, string filename)
    {
      if (filename != "")
        execute_command_sync("rm -r '%s'".printf(filename));
        stdout.printf("DEBUG: deleted '%s'\n".printf(filename));
      dialog.destroy();
    }

    private Gee.ArrayList<string> get_files_selection()
    {
      var list = new Gee.ArrayList<string>();
      List<Gtk.TreePath> paths = view.get_selected_items();
      GLib.Value filepath;
      foreach (Gtk.TreePath path in paths)
      {
        model.get_iter(out iter, path);
        model.get_value(iter, 2, out filepath);
        list.add((string)filepath);
      }
      return list;
    }

    public void execute_command_async(string item_name)
    {
      try
      {
        Process.spawn_command_line_async(item_name);
      }
      catch (GLib.Error e)
      {
        stderr.printf ("%s\n", e.message);
      }
    }
    
    public void execute_command_sync(string item_name)
    {
      try
      {
        Process.spawn_command_line_sync(item_name);
      }
      catch (GLib.Error e)
      {
        stderr.printf ("%s\n", e.message);
      }
    }
  }
}
