namespace Vestigo
{
  public class PdfPreview: GLib.Object
  {
    Gdk.Pixbuf? pix = null; 
    
    public async Gdk.Pixbuf get_pdf_preview_from_file_name(string name)
    {  
      string thumb_dir = GLib.Path.build_filename(GLib.Environment.get_home_dir(), ".thumbnails/large");
      string checksum = new Vestigo.Checksum().get_file_md5(name);
      string thumb_name = GLib.Path.build_filename(thumb_dir, checksum + ".png");
      var thumb_file = File.new_for_path(thumb_name);
      
      if (thumb_file.query_exists() == true)
      {
        print("%s\n", "DEBUG: pdf preview found in .thumbnails/large");
        
        try
        {
          GLib.InputStream stream = yield thumb_file.read_async();
          pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, thumbnail_size, thumbnail_size, true, null);
        }
        catch (Error e)
        {
          stderr.printf("%s\n", e.message);
        }
        return pix;
      }
      else
      {
        print("%s\n", "DEBUG: pdf preview not found");
        
        Poppler.Document document = null;
        
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
        try
        {
          document = new Poppler.Document.from_file(GLib.Filename.to_uri(name), "");
        }
        catch (GLib.Error e)
        {
          error ("%s\n", e.message);
        }
        double width;
        double height;
        var page = document.get_page(0);
        page.get_size(out width, out height);

        var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32, (int)width, (int)height);
        var context = new Cairo.Context(surface);
        
        page.render(context);
        surface.write_to_png(thumb_name);
        GLib.FileUtils.chmod(thumb_name, 0600);
        
        try
        {
          GLib.InputStream stream = yield thumb_file.read_async();
          pix = yield new Gdk.Pixbuf.from_stream_at_scale_async(stream, thumbnail_size, thumbnail_size, true, null);
        }
        catch (Error e)
        {
          stderr.printf("%s\n", e.message);
        }
        return pix;
      }
    }
    
  }
}
