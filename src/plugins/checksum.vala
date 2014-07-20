namespace Vestigo
{
  public class Checksum: GLib.Object
  {
    public string get_file_md5(string name)
    {
      uint8[] contents;
      try
      {
        FileUtils.get_data(name, out contents);
      }
      catch (GLib.FileError e)
      {
        stdout.printf("%s/n", e.message);
      }
      string checksum = GLib.Checksum.compute_for_data(ChecksumType.MD5, contents);
      return checksum;
    }
  }
}
