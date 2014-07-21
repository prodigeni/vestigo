namespace Vestigo
{
  const string NAME        = "Vestigo";
  const string VERSION     = "0.0.3";
  const string DESCRIPTION = _("File manager in Vala and GTK3");
  const string ICON        = "vestigo";
  const string[] AUTHORS   = { "Simargl <archpup-at-gmail-dot-com>", null };

  Gtk.ApplicationWindow window;
  Gtk.Button button_prev;
  Gtk.Button button_up;
  Gtk.HeaderBar headerbar;
  Gtk.IconView view;
  Gtk.ListStore model;
  Gtk.Menu menu;
  Gtk.MenuButton menubutton;
  Gtk.PlacesSidebar places; 
  Gtk.TreeIter iter;

  int width;
  int height;
  int icon_size;
  int thumbnail_size;
  string saved_dir;
  string terminal;
  
  string current_dir;
  Gee.ArrayList<string> history;
  Gee.ArrayList<string> files_copy;
  Gee.ArrayList<string> files_cut;
}  
  