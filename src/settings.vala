namespace Vestigo
{
  public class Settings : GLib.Object
  {
    GLib.Settings settings; 

    public void get_settings()
    {
      settings = new GLib.Settings("org.alphaos.vestigo.preferences");
      width = settings.get_int("width");
      height = settings.get_int("height");
      icon_size = settings.get_int("icon-size"); 
      thumbnail_size = settings.get_int("thumbnail-size");
      saved_dir = settings.get_string("saved-dir");
      terminal = settings.get_string("terminal");
    }
    
    public void save_settings()
    {
      window.get_size(out width, out height);
      settings = new GLib.Settings("org.alphaos.vestigo.preferences");
      settings.set_int("width", width);
      settings.set_int("height", height);
      settings.set_string("saved-dir", current_dir);
      GLib.Settings.sync();
    }
  }
}
