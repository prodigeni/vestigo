namespace Vestigo
{
  uint timeout_id = 0;
  
  public class DirectoryMonitor: GLib.Object
  {
    public GLib.FileMonitor current_monitor { get; private set; default = null; }

    public DirectoryMonitor()
    {
      timeout_id = GLib.Timeout.add(500, (GLib.SourceFunc)setup_file_monitor, 0);
    }

    public void setup_file_monitor()
    {
      try
      {
        //print("DEBUG: starting FileMonitor in %s\n", current_dir);
        
        var file = GLib.File.new_for_path(current_dir);
        current_monitor = file.monitor_directory(GLib.FileMonitorFlags.NONE);
        current_monitor.changed.connect(on_file_changed);
      }
      catch (GLib.Error e)
      {
        stderr.printf("%s\n", e.message);
      }
    }  

    private void on_file_changed(GLib.File src, GLib.File? dest, GLib.FileMonitorEvent event)
    {
      //print("DEBUG: %s changed\n", current_dir);
      new Vestigo.IconView().open_location(GLib.File.new_for_path(current_dir), false);
    }

  }
}
