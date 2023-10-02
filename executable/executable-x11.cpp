#include "../include/devtemplate/devtemplate.h"
#include <X11/Xlib.h>
#include <string.h>
#include <iostream>
#include <stdexcept>

int main()
{
    try
    {
        // Open window
        Display *display = XOpenDisplay(NULL);
        if (display == nullptr) throw std::runtime_error("XOpenDisplay failed");
        int screen = DefaultScreen(display);
        Window window = XCreateSimpleWindow(display, RootWindow(display, screen), 10, 10, 300, 200, 1, BlackPixel(display, screen), WhitePixel(display, screen));
        XSelectInput(display, window, ExposureMask | KeyPressMask);
        XMapWindow(display, window);
        XStoreName(display, window, "Devtemplate GUI");
        Atom WM_DELETE_WINDOW = XInternAtom(display, "WM_DELETE_WINDOW", False);
        XSetWMProtocols(display, window, &WM_DELETE_WINDOW, 1);

        // Loop
        XEvent event;
        while (true)
        {
            XNextEvent(display, &event);
            if (event.type == Expose)
            {
                devtemplate::Devtemplate d;
                #ifndef DEVTEMPLATE_ADVANCED
                    const char *text = (d.devtemplate() == 42) ? "Devtemplate is functioning correctly" : "Devtemplate is malfunctioning";
                #else
                    const char *text = (d.devtemplate_advanced() == 43) ? "Advanced Devtemplate is functioning correctly" : "Advanced Devtemplate is malfunctioning";
                #endif
                XDrawString(display, window, DefaultGC(display, screen), 10, 20, text, strlen(text));
            }
            else if ((event.type == ClientMessage) && (event.xclient.data.l[0] == WM_DELETE_WINDOW))
            {
                break;
            }
        }
        
        // Terminate
        XDestroyWindow(display, window);
        XCloseDisplay(display);
        return 0;
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
    }
}