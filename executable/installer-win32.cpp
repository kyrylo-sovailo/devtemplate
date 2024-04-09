#include <Windows.h>
#include <CommCtrl.h>
#include <RichEdit.h>
#include <string>
#include <iostream>
#include <stdexcept>
#include <memory>

#pragma region Framework definitions
class Control
{
protected:
    HWND _handle = NULL;

public:
    HWND handle() const;
    ~Control();
};

class Parent : public Control
{
protected:
    bool _white = false;

public:
    bool white() const;
};

class Font
{
protected:
    HFONT _handle = (HFONT)NULL;

public:
    Font(unsigned int size, bool bold, bool italic);
    HFONT handle() const;
    ~Font();
};

class Label : public Control
{
public:
    Label(const Parent *parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height);
};

class Richedit : public Control
{
public:
    Richedit(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height);
};

class Edit : public Control
{
public:
    Edit(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height);
    std::wstring get() const;
};

class Button : public Control
{
protected:
    WORD _identifier = 0;
    static WORD _identifier_generator;
    Button();

public:
    Button(const Parent *parent, const Font* font, const TCHAR* text, bool capture, unsigned int left, unsigned int top, unsigned int width, unsigned int height);
    bool identify(WPARAM wparam) const;
};

class Checkbox : public Button
{
public:
    Checkbox(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height);
    void set(bool check);
    bool get() const;
};

class Progress : public Control
{
public:
    Progress(const Parent *parent, int unsigned range, int unsigned left, int unsigned top, int unsigned width, int unsigned height);
    void step();
};

class Panel : public Parent
{
public:
    Panel(const Parent *parent, bool white, int unsigned left, int unsigned top, int unsigned width, int unsigned height);
};

class Groupbox : public Parent
{
public:
    Groupbox(const Parent* parent, const Font* font, const TCHAR* text, int unsigned left, int unsigned top, int unsigned width, int unsigned height);
};
#pragma endregion

class Window : public Parent
{
private:
    WNDCLASSEX _window_class;

    //Common
    std::unique_ptr<Font> _common_font;
    std::unique_ptr<Font> _bold_font;
    std::unique_ptr<Font> _big_font;
    std::unique_ptr<Button> _button_next;
    std::unique_ptr<Button> _button_cancel;

    //Welcome screen
    std::unique_ptr<Panel> _panel_welcome;
    std::unique_ptr<Label> _label_welcome;
    std::unique_ptr<Label> _label_line1;
    std::unique_ptr<Label> _label_line2;
    std::unique_ptr<Label> _label_line3;

    static LRESULT CALLBACK _handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam);

public:
    Window(HINSTANCE hinstance);
    void initialize(HWND handle);
    int run();
    ~Window();
};

#pragma region Framework implementation
HWND Control::handle() const
{
    return _handle;
}

Control::~Control()
{
    DestroyWindow(_handle);
}

bool Parent::white() const
{
    return _white;
}

Font::Font(unsigned int size, bool bold, bool italic)
{
    NONCLIENTMETRICS metrics;
    metrics.cbSize = sizeof(NONCLIENTMETRICS);
    SystemParametersInfo(SPI_GETNONCLIENTMETRICS, sizeof(NONCLIENTMETRICS), &metrics, 0);
    metrics.lfMessageFont.lfHeight = -static_cast<int>(size);
    if (bold) metrics.lfMessageFont.lfWeight = FW_BOLD;
    metrics.lfMessageFont.lfItalic = italic;
    _handle = CreateFontIndirect(&metrics.lfMessageFont);
    if (_handle == NULL) throw std::runtime_error("CreateFontIndirect failed");
}

HFONT Font::handle() const
{
    return _handle;
}

Font::~Font()
{
    DeleteObject(_handle);
}

Label::Label(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height)
{
    _handle = CreateWindowEx(WS_EX_TRANSPARENT, TEXT("STATIC"), text, WS_VISIBLE | WS_CHILD |
        SS_LEFT, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

Richedit::Richedit(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height)
{
    const TCHAR *clas;
    if (LoadLibrary(TEXT("Msftedit.dll")) != NULL) clas = MSFTEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched20.dll")) != NULL) clas = RICHEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched32.dll")) != NULL) clas = RICHEDIT_CLASS;
    else throw std::runtime_error("Could not load Rich Edit");

    _handle = CreateWindowEx(0, clas, text, WS_VISIBLE | WS_CHILD |
        ES_SUNKEN | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

Edit::Edit(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height)
{
    _handle = CreateWindowEx(0, TEXT("EDIT"), text, WS_VISIBLE | WS_CHILD |
        SS_LEFT, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

std::wstring Edit::get() const
{
    std::wstring buffer(512, '\0');
    while (true)
    {
        int len = GetWindowText(_handle, &buffer[0], buffer.size());
        if (len < 0) throw std::runtime_error("GetWindowText failed");
        else if (len == buffer.size() - 1) buffer.resize(2 * buffer.size());
        else break;
    }
    return buffer;
}

WORD Button::_identifier_generator = 0;

Button::Button() { }

Button::Button(const Parent* parent, const Font* font, const TCHAR* text, bool capture, unsigned int left, unsigned int top, unsigned int width, unsigned int height)
{
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, WS_VISIBLE | WS_CHILD |
        BS_CENTER | BS_TEXT | BS_VCENTER | (capture ? BS_DEFPUSHBUTTON : 0), left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    _identifier = _identifier_generator++;
}

bool Button::identify(WPARAM wparam) const
{
    return LOWORD(wparam) == _identifier;
}

Checkbox::Checkbox(const Parent* parent, const Font* font, const TCHAR* text, unsigned int left, unsigned int top, unsigned int width, unsigned int height)
{
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, WS_VISIBLE | WS_CHILD |
        BS_CENTER | BS_TEXT | BS_VCENTER, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    _identifier = _identifier_generator++;
}

void Checkbox::set(bool check)
{
    SendMessage(_handle, check ? BST_CHECKED : BST_UNCHECKED, 0, 0);
}

bool Checkbox::get() const
{
    return SendMessage(_handle, BM_GETCHECK, 0, 0) == BST_CHECKED;
}

Progress::Progress(const Parent *parent, int unsigned range, int unsigned left, int unsigned top, int unsigned width, int unsigned height)
{
    _handle = CreateWindowEx(0, PROGRESS_CLASS, TEXT("progress"), WS_VISIBLE | WS_CHILD |
        BS_CENTER | BS_TEXT | BS_VCENTER, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, PBM_SETRANGE, 0, MAKELPARAM(0, range));
    SendMessage(_handle, PBM_SETSTEP, (WPARAM)1, 0);
}

void Progress::step()
{
    SendMessage(_handle, PBM_STEPIT, 0, 0);
}

Panel::Panel(const Parent *parent, bool white, int unsigned left, int unsigned top, int unsigned width, int unsigned height)
{
    _white = white;
    _handle = CreateWindowEx(0, TEXT("STATIC"), TEXT(""),
        WS_VISIBLE | WS_CHILD | (white ? SS_WHITERECT : SS_WHITEFRAME), left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
}

Groupbox::Groupbox(const Parent *parent, const Font *font, const TCHAR *text, int unsigned left, int unsigned top, int unsigned width, int unsigned height)
{
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text,
        WS_VISIBLE | WS_CHILD | BS_GROUPBOX, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}
#pragma endregion

LRESULT CALLBACK Window::_handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam)
{
    switch (message)
    {
    case WM_CREATE:
    {
        try
        {
            Window* window = static_cast<Window*>((reinterpret_cast<CREATESTRUCT*>(lparam))->lpCreateParams);
            window->initialize(handle);
            return 0;
        }
        catch (const std::exception& e)
        {
            std::cerr << e.what() << std::endl;
            return -1;
        }
    }
    case BN_CLICKED:
    {
        return 0;
    }
    case WM_CLOSE:
    {
        DestroyWindow(handle);
        return 0;
    }
    case WM_ERASEBKGND:
    {
        HDC hdc = (HDC)(wparam);
        RECT rect;
        GetClientRect(handle, &rect);
        HBRUSH brush = GetSysColorBrush(COLOR_MENU);
        FillRect(hdc, &rect, brush);
        return 0;
    }
    case WM_CTLCOLORSTATIC:
    {
        HDC hdc = (HDC)wparam;
        SetBkMode(hdc, TRANSPARENT);
        return (LRESULT)GetStockObject(NULL_BRUSH);
    }
    case WM_DESTROY:
    {
        PostQuitMessage(0);
        return 0;
    }
    default:
        return DefWindowProc(handle, message, wparam, lparam);
    }
}

Window::Window(HINSTANCE hinstance)
{
    //Parameters
    const TCHAR* name = TEXT("INSTALLER");
    const TCHAR* caption = TEXT("Installer");
    const int width = 600;
    const int height = 490;

    //Register class
    memset(&_window_class, 0, sizeof(_window_class));
    _window_class.cbSize = sizeof(_window_class);
    _window_class.lpfnWndProc = _handler;
    _window_class.hInstance = hinstance;
    _window_class.lpszClassName = name;
    _window_class.hIcon = _window_class.hIconSm = LoadIcon(hinstance, MAKEINTRESOURCE(1000));
    if (RegisterClassEx(&_window_class) == 0) throw std::runtime_error("RegisterClassEx failed");

    //Create window
    _handle = CreateWindowEx(0, name, caption,
        WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE, CW_USEDEFAULT,
        CW_USEDEFAULT, width, height, NULL, NULL, hinstance, this);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
}

void Window::initialize(HWND handle)
{
    _handle = handle;
    RECT rect;
    GetClientRect(_handle, &rect);
    const unsigned int width = rect.right - rect.left;
    const unsigned int height = rect.bottom - rect.top;

    //Common
    _common_font = std::unique_ptr<Font>(new Font(12, false, false));
    _bold_font = std::unique_ptr<Font>(new Font(12, true, false));
    _big_font = std::unique_ptr<Font>(new Font(20, true, false));
    _button_next = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Next >"), true, width - 200, height - 40, 85, 25));
    _button_cancel = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Cancel"), false, width - 100, height - 40, 85, 25));

    //Welcome screen
    _panel_welcome = std::unique_ptr<Panel>(new Panel(this, true, 0, 0, width, height - 60));
    _label_welcome = std::unique_ptr<Label>(new Label(this, _big_font.get(), TEXT("Welcome"), 20, 25, width - 40, 30));
}

int Window::run()
{
    MSG message = { };
    while (GetMessage(&message, NULL, 0, 0) > 0)
    {
        TranslateMessage(&message);
        DispatchMessage(&message);
    }
    return static_cast<int>(message.wParam);
}

Window::~Window()
{
    DestroyWindow(_handle);
}

#pragma region Entry function
int _main(HINSTANCE hinstance)
{
    try
    {
        Window window(hinstance);
        return window.run();
    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        return 1;
    }
}

extern "C" int APIENTRY WinMain(HINSTANCE hinstance, HINSTANCE, PSTR, int)
{
    return _main(hinstance);
}
#pragma endregion