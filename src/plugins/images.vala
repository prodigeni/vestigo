namespace Vestigo
{
  public class Images: GLib.Object
  {
    Gdk.Pixbuf? pix = null; 
    
    public async Gdk.Pixbuf get_thumbnail_from_file_name(string name)
    {
      if (current_dir.contains(".thumbnails") != true)
      {
        string thumb_dir = GLib.Path.build_filename(GLib.Environment.get_home_dir(), ".thumbnails/normal");
        string checksum = new Vestigo.Checksum().get_file_md5(name);
        string thumb_name = GLib.Path.build_filename(thumb_dir, checksum + ".png");
        var thumb_file = File.new_for_path(thumb_name);
        
        if (thumb_file.query_exists() == true)
        {
          print("%s\n", "DEBUG: image preview found in .thumbnails/normal");
          
          try
          {
            GLib.InputStream stream = yield thumb_file.read_async();
            pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, thumbnail_size, thumbnail_size, true, null);
          }
          catch (Error e)
          {
            stderr.printf("%s\n", e.message);
          }
        }
        else
        {
          print("%s\n", "DEBUG: image preview not found");
          
          var file = GLib.File.new_for_path(name);

          try
          {
            GLib.InputStream stream = yield file.read_async();
            pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, thumbnail_size, thumbnail_size, true, null);
            
            var check_dir = File.new_for_path(thumb_dir);
            if (check_dir.query_exists() == false)
              try
              {
		        check_dir.make_directory_with_parents();
              }
              catch (GLib.Error e)
              {
                error ("%s\n", e.message);
              }
            
            pix.save(thumb_name, "png");
            GLib.FileUtils.chmod(thumb_name, 0600);
          }
          catch (Error e)
          {
            stderr.printf("%s\n", e.message);
          }
        }
      }
      else
      {
        pix = load_fallback_icon();
      }
      return pix;
    }

    private Gdk.Pixbuf load_fallback_icon()
    {
      try
      {
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
        pix = icon_theme.load_icon("image-x-generic", icon_size, 0);
      }
      catch (GLib.Error e)
      {
        error("%s\n", e.message);
      }
      return pix;
    }

  }
}
