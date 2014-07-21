namespace Vestigo
{
  public class Menu: GLib.Object
  {
    public Gtk.Menu activate_file_menu()
    {
      var file_cut = new Gtk.MenuItem.with_label(_("Cut"));
      var file_copy = new Gtk.MenuItem.with_label(_("Copy"));
      var file_rename = new Gtk.MenuItem.with_label(_("Rename"));
      var file_delete = new Gtk.MenuItem.with_label(_("Delete"));

      menu = new Gtk.Menu();
      menu.append(file_cut);
      menu.append(file_copy);
      menu.append(file_rename);
      menu.append(file_delete);

      var op = new Vestigo.Operations();

      file_cut.activate.connect(() => { op.file_cut_activate(); });
      file_copy.activate.connect(() => { op.file_copy_activate(); });
      file_rename.activate.connect(() => { op.file_rename_activate(); });
      file_delete.activate.connect(() => { op.file_delete_activate(); });

      menu.show_all();

      return menu;
    }
    
    public Gtk.Menu activate_context_menu()
    {
      var context_folder = new Gtk.MenuItem.with_label(_("Create Folder"));
      var context_file = new Gtk.MenuItem.with_label(_("Create File"));
      var context_separator1 = new Gtk.SeparatorMenuItem();
      var context_paste = new Gtk.MenuItem.with_label(_("Paste"));
      var context_separator2 = new Gtk.SeparatorMenuItem();
      var context_bookmark = new Gtk.MenuItem.with_label(_("Add to Bookmarks"));
      var context_terminal = new Gtk.MenuItem.with_label(_("Open in Terminal"));

      var op = new Vestigo.Operations();

      context_folder.activate.connect(() => { op.make_new(false); });
      context_file.activate.connect(() => { op.make_new(true); });
      context_paste.activate.connect(() => { op.file_paste_activate(); });
      context_bookmark.activate.connect(() => { op.add_bookmark(); });
      context_terminal.activate.connect(() => { op.execute_command_async("%s '%s'".printf(terminal, current_dir)); });

      menu = new Gtk.Menu();
      menu.append(context_folder);
      menu.append(context_file);
      menu.append(context_separator1);
      menu.append(context_paste);
      menu.append(context_separator2);
      menu.append(context_bookmark);
      menu.append(context_terminal);
      menu.show_all();

      return menu;
    }    
    
  }
}
