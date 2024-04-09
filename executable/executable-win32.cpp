#include <devtemplate/devtemplate.h>

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

        //Draw text
        devtemplate::Devtemplate d;
        #ifndef DEVTEMPLATE_ADVANCED
            const bool correct = d.calculate() == 42;
        #else
            const bool correct = d.calculate_advanced() == 43;
        #endif
        std::string text = devtemplate::Devtemplate::version() + (correct ? " is functioning correctly" : " is malfunctioning");
        
        std::basic_string<TCHAR> ttext(text.size(), '\0');
        for (size_t i = 0; i < text.size(); i++) ttext[i] = static_cast<TCHAR>(text[i]);
        ExtTextOut(hdc, 0, 0, ETO_OPAQUE, &client_rect, ttext.c_str(), static_cast<UINT>(ttext.size()), NULL);

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
        WNDCLASSEX window_class;
        memset(&window_class, 0, sizeof(window_class));
        window_class.cbSize = sizeof(window_class);
        window_class.lpfnWndProc = handler;
        window_class.hInstance = hinstance;
        window_class.lpszClassName = TEXT("devtemplate");
        window_class.hIcon = window_class.hIconSm = LoadIcon(hinstance, MAKEINTRESOURCE(1000));
        if (RegisterClassEx(&window_class) == 0) throw std::runtime_error("RegisterClassEx failed");

        //Create window
        HWND hwnd = CreateWindowEx(0, TEXT("devtemplate"), TEXT("Devtemplate"),
		WS_OVERLAPPEDWINDOW | WS_VISIBLE, CW_USEDEFAULT, CW_USEDEFAULT, 600, 200, NULL, NULL, hinstance, NULL);
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
    int WINAPI WinMain(_In_ HINSTANCE hinstance, _In_opt_ HINSTANCE, _In_ PSTR, _In_ int)
	{
		return _main(hinstance);
	}
#else
	int main()
	{
		return _main(GetModuleHandle(NULL));
	}
#endif