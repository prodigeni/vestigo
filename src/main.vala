/*  Copyright (c) alphaOS
 *  Written by simargl <archpup-at-gmail-dot-com>
 *  
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Vestigo
{
  private class Main: Gtk.Application
  {
    public Main()
    {
      Object(application_id: "org.alphaos.vestigo", flags: GLib.ApplicationFlags.FLAGS_NONE);
    }

    public override void startup()
    {
      base.startup();
      
      new Vestigo.Window().add_app_window(this);
    }
    
    public override void activate() 
    {
      get_active_window().present();
    }

    private static int main (string[] args)
    {
      Vestigo.Main app = new Vestigo.Main();
      return app.run(args);
    }
  }
}
