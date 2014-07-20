namespace Vestigo
{
  public class Menu: GLib.Object
  {
    public Gtk.Menu activate_file_menu()
    {
      var file_menu1 = new Gtk.MenuItem.with_label("file_menu1");
      var file_menu2 = new Gtk.MenuItem.with_label("file_menu2");
      var file_menu3 = new Gtk.MenuItem.with_label("file_menu3");

      var menu = new Gtk.Menu();
      menu.append(file_menu1);
      menu.append(file_menu2);      
      menu.append(file_menu3);      
      menu.show_all();

      return menu;
    }
    
    public Gtk.Menu activate_context_menu()
    {
      var context_menu1 = new Gtk.MenuItem.with_label("context_menu1");
      var context_menu2 = new Gtk.MenuItem.with_label("context_menu2");
      var context_menu3 = new Gtk.MenuItem.with_label("context_menu3");

      var menu = new Gtk.Menu();
      menu.append(context_menu1);
      menu.append(context_menu2);      
      menu.append(context_menu3);      
      menu.show_all();

      return menu;
    }    
    
  }
}
