#include "../include/devtemplate/devtemplate.h"

#include <png.h>
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <unistd.h>

#include <stdexcept>
#include <iostream>
#include <string>
#include <vector>
#include <string.h>
#include <stdlib.h>

#define STRING(s) #s

std::string get_directory()
{
    std::string path(128, '\0');
    while (true)
    {
        int len = readlink("/proc/self/exe", &path[0], path.length());
        if (len < 0) throw std::runtime_error("Failed to read executabe path");
        else if (len == path.length()) path.resize(path.size() * 2);
        else break;
    }
    if (path.find_last_of('/') == std::string::npos) throw std::runtime_error("Failed to read executabe directory");
    path.resize(path.find_last_of('/'));
    return path;
}

void load_icon(const std::string directory, std::vector<unsigned long> *data, unsigned int size)
{
    //Find png
    std::string size_string = std::to_string(size) + "x" + std::to_string(size);
    std::string path_probe = directory + "/../share/icons/hicolor/" + size_string + "/apps/" DEVTEMPLATE_FILE_NAME "_executable_gui.png";
    FILE *file = fopen(path_probe.c_str(), "r");
    if (file == nullptr)
    {
        path_probe = directory + "/../icon/" + size_string + ".png";
        file = fopen(path_probe.c_str(), "r");
        if (file == nullptr)
        {
            path_probe = directory + "/icon/" + size_string + ".png";
            file = fopen(path_probe.c_str(), "r");
            if (file == nullptr) throw std::runtime_error("Failed to open file");
        }
    }
    
    //Prepare to read png
    unsigned char signature[8];
    if (fread(signature, 1, 8, file) != 8 || !png_check_sig(signature, 8)) throw std::runtime_error("Failed to verify signature");
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    if (png == nullptr) throw std::runtime_error("Failed to initialize png structure");
    png_infop info = png_create_info_struct(png);
    if (info == nullptr) throw std::runtime_error("Failed to initialize png info structure");
    png_init_io(png, file);
    png_set_sig_bytes(png, 8);
    png_read_info(png, info);
    png_uint_32 width, height;
    int  bit_depth, color_type;
    png_get_IHDR(png, info, &width, &height, &bit_depth, &color_type, nullptr, nullptr, nullptr);
    if (width != size || height != size) throw std::runtime_error("Invalid image size");
    
    //Read png
    if (color_type == PNG_COLOR_TYPE_PALETTE) png_set_expand(png);
    if (color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8) png_set_expand(png);
    if (png_get_valid(png, info, PNG_INFO_tRNS)) png_set_expand(png);
    if (bit_depth == 16) png_set_strip_16(png);
    if (color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA) png_set_gray_to_rgb(png);
    double gamma;
    if (png_get_gAMA(png, info, &gamma)) png_set_gamma(png, 2.2, gamma);
    png_read_update_info(png, info);
    if (png_get_rowbytes(png, info) != size * 4) throw std::runtime_error("Invalid row size");
    std::vector<unsigned char> image(size * size * 4);
    std::vector<unsigned char*> rows(size);
    for (unsigned int i = 0; i < size; i++) rows[i] = image.data() + (size * i * 4);
    png_read_image(png, rows.data());

    //Finalize png reading
    png_read_end(png, nullptr);
    png_destroy_read_struct(&png, &info, nullptr);
    fclose(file);

    //Convert to X11 format
    data->reserve(data->size() + 2 + size * size);
    data->push_back(size);
    data->push_back(size);
    for (unsigned int i = 0; i < size * size; i++)
        data->push_back((image[i * 4 + 0] << 16) | (image[i * 4 + 1] << 8) | (image[i * 4 + 2]) | (image[i * 4 + 3] << 24));
}

int main()
{
    try
    {
        // Open window
        Display *display = XOpenDisplay(nullptr);
        if (display == nullptr) throw std::runtime_error("XOpenDisplay failed");
        int screen = DefaultScreen(display);
        Window window = XCreateSimpleWindow(display, RootWindow(display, screen), 10, 10, 300, 200, 1, BlackPixel(display, screen), WhitePixel(display, screen));
        XSelectInput(display, window, ExposureMask | KeyPressMask);
        XMapWindow(display, window);
        XStoreName(display, window, "Devtemplate GUI");
        Atom WM_DELETE_WINDOW = XInternAtom(display, "WM_DELETE_WINDOW", false);
        if (WM_DELETE_WINDOW == 0) throw std::runtime_error("XOpenDisplay failed");
        XSetWMProtocols(display, window, &WM_DELETE_WINDOW, 1);

        // Set icon
        Atom _NET_WM_ICON = XInternAtom(display, "_NET_WM_ICON", false);
        std::string directory = get_directory();
        std::vector<unsigned long> data;
        load_icon(directory, &data, 16);
        load_icon(directory, &data, 24);
        load_icon(directory, &data, 32);
        load_icon(directory, &data, 48);
        load_icon(directory, &data, 64);
        load_icon(directory, &data, 128);
        load_icon(directory, &data, 256);
        XChangeProperty(display, window, _NET_WM_ICON, XA_CARDINAL, 32, PropModeReplace, (unsigned char*) data.data(), data.size());

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
        return 1;
    }
}