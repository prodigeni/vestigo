namespace Vestigo
{
  public class Operations: GLib.Object
  {

    public void make_new(bool file)
    {
      string entry_title = null;
      string typed = null;
      
      if (file == true)
        entry_title = _("Create file");
      else
        entry_title = _("Create folder");
        
      var dialog = new Gtk.Dialog();
      dialog.set_title(entry_title);
      dialog.set_border_width(10);
      dialog.set_property("skip-taskbar-hint", true);
      dialog.set_transient_for(window);
      dialog.set_resizable(false);

      var entry = new Gtk.Entry();
      entry.set_size_request(190, 0);
      entry.activate.connect(() => { typed = entry.get_text(); on_dialog_response(entry, dialog, typed, file); });

      var content = dialog.get_content_area() as Gtk.Box;
      content.pack_start(entry, true, true, 10);

      dialog.add_button(_("Create"), Gtk.ResponseType.OK);
      dialog.add_button(_("Close"), Gtk.ResponseType.CLOSE);
      dialog.set_default_response(Gtk.ResponseType.OK);
      dialog.show_all();
      
      if (dialog.run() == Gtk.ResponseType.OK)
      {
        typed = entry.get_text();
        on_dialog_response(entry, dialog, typed, file);
      }
      dialog.destroy();
    }

    private void on_dialog_response(Gtk.Entry entry, Gtk.Dialog dialog, string typed, bool file)
    {
      if (typed != "")
        if (file == true)
          execute_command_sync("touch %s".printf(GLib.Path.build_filename(current_dir, typed)));
        else
          execute_command_sync("mkdir %s".printf(GLib.Path.build_filename(current_dir, typed)));
      dialog.destroy();
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
