#include "../include/devtemplate/devtemplate.h"
#include <Windows.h>
#include <string>
#include <iostream>
#include <stdexcept>

LRESULT CALLBACK handler(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam)
{
	switch (message)
	{
    case WM_PAINT:
    {
        //Begin paint
        RECT client_rect;
        GetClientRect(hwnd, &client_rect);
        PAINTSTRUCT paint;
        HDC hdc = BeginPaint(hwnd, &paint);

        //Select objects
        SetTextColor(hdc, GetSysColor(COLOR_WINDOWTEXT)); 
        SetBkColor(hdc, GetSysColor(COLOR_WINDOW));
        HFONT hfont = (HFONT)GetStockObject(SYSTEM_FONT);

        //Draw text
        devtemplate::Devtemplate d;
        bool correct, advanced;
        #ifndef DEVTEMPLATE_ADVANCED
            correct = d.devtemplate() == 42;
            advanced = false;
        #else
            correct = d.devtemplate_advanced() == 43;
            advanced = true;
        #endif
        std::basic_string<TCHAR> text;
        if (advanced) text += TEXT("Advanced Devtemplate"); else text += TEXT("Devtemplate");
        if (sizeof(void*) == 8) text += TEXT(" (64 bit)"); else text += TEXT(" (32 bit)");
        if (correct) text += TEXT(" is functioning correctly"); else text += TEXT(" is malfunctioning");
        
        ExtTextOut(hdc, 0, 0, ETO_OPAQUE, &client_rect, text.c_str(), static_cast<UINT>(text.size()), NULL);

        //End paint
        EndPaint(hwnd, &paint);
        break;
    }
	case WM_CLOSE:
	{
		DestroyWindow(hwnd);
		break;
	}
	case WM_DESTROY:
	{
		PostQuitMessage(0);
		break;
	}
	default:
		return DefWindowProc(hwnd, message, wparam, lparam);
	}
	return 0;
}

int _main(HINSTANCE hinstance)
{
    try
    {
        //Register class
        WNDCLASSEX window_class = { 0 };
        window_class.cbSize = sizeof(window_class);
        window_class.lpfnWndProc = handler;
        window_class.hInstance = hinstance;
        window_class.lpszClassName = TEXT("devtemplate");
        window_class.hIcon = window_class.hIconSm = LoadIcon(hinstance, MAKEINTRESOURCE(1000));
		DWORD error = GetLastError();
        if (RegisterClassEx(&window_class) == 0) throw std::runtime_error("RegisterClassEx failed");

        //Create window
        HWND hwnd = CreateWindowEx(0, TEXT("devtemplate"), TEXT("Devtemplate"),
		WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 300, 200, NULL, NULL, hinstance, NULL);
        if (hwnd == NULL) throw std::runtime_error("CreateWindowEx failed");

        //Loop
        MSG message = { };
        while (GetMessage(&message, NULL, 0, 0) > 0)
        {
            TranslateMessage(&message);
            DispatchMessage(&message);
        }

        //Terminate
        return static_cast<int>(message.wParam);
    }
    catch (const std::exception &e)
    {
        std::cerr << e.what() << std::endl;
        return 1;
    }
}

#ifdef DEV_WIN32_EXECUTABLE
	extern "C" int APIENTRY WinMain(HINSTANCE hinstance, HINSTANCE hprevious, PSTR cmdline, int cmdshow)
	{
		return _main(hinstance);
	}
#else
	int main()
	{
		return _main(GetModuleHandle(NULL));
	}
#endif