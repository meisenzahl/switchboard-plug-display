/*-
 * Copyright (c) 2014-2018 elementary LLC.
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 * Authored by: Corentin Noël <corentin@elementary.io>
 */

namespace Display.Utils {
    public static bool has_touchscreen () {
        weak Gdk.Display? display = Gdk.Display.get_default ();
        if (display != null) {
            var manager = display.get_device_manager ();
            GLib.List<weak Gdk.Device> devices = manager.list_devices (Gdk.DeviceType.SLAVE);
            foreach (weak Gdk.Device device in devices) {
                if (device.input_source == Gdk.InputSource.TOUCHSCREEN) {
                    return true;
                }
            }
        }

        return false;
    }

    public static Gee.LinkedList<Display.MonitorMode> get_common_monitor_modes (Gee.LinkedList<Display.Monitor> monitors) {
        var common_modes = new Gee.LinkedList<Display.MonitorMode> ();
        double min_scale = get_min_compatible_scale (monitors);
        bool first_monitor = true;
        foreach (var monitor in monitors) {
            if (first_monitor) {
                foreach (var mode in monitor.modes) {
                    if (min_scale in mode.supported_scales) {
                        common_modes.add (mode);
                    }
                }

                first_monitor = false;
            } else {
                var to_remove = new Gee.LinkedList<Display.MonitorMode> ();
                foreach (var mode_to_check in common_modes) {
                    bool mode_found = false;
                    foreach (var monitor_mode in monitor.modes) {
                        if (mode_to_check.width == monitor_mode.width &&
                            mode_to_check.height == monitor_mode.height) {
                            mode_found = true;
                            break;
                        }
                    }

                    if (mode_found == false) {
                        to_remove.add (mode_to_check);
                    }
                }

                common_modes.remove_all (to_remove);
            }
        }

        return common_modes;
    }

    public static double get_min_compatible_scale (Gee.LinkedList<Display.Monitor> monitors) {
        double min_scale = 0.0;
        foreach (var monitor in monitors) {
            min_scale = double.max (min_scale, monitor.get_min_scale ());
        }

warning ("UTILS min compat scale %f", min_scale);
        return min_scale;
    }
    public static double get_max_compatible_scale (Gee.LinkedList<Display.Monitor> monitors) {
        double max_scale = double.MAX;
        foreach (var monitor in monitors) {
            max_scale = double.min (max_scale, monitor.get_max_scale ());
        }

warning ("UTILS max compat scale %f", max_scale);
        return max_scale;
    }
}
