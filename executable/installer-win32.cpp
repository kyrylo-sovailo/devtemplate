#include <Windows.h>
#include <CommCtrl.h>
#include <RichEdit.h>
#include <string>
#include <iostream>
#include <stdexcept>

#define DEV_STRING2(s) #s
#define DEV_STRING(s) DEV_STRING2(s)
#define DEV_NAME_VERSION DEV_STRING(DEVTEMPLATE_NAME) " " DEV_STRING(DEVTEMPLATE_MAJOR) "." DEV_STRING(DEVTEMPLATE_MINOR) "." DEV_STRING(DEVTEMPLATE_PATCH)

#pragma region Framework definitions
class Control
{
protected:
    HWND _handle = NULL;

public:
    void set_visible(bool visible);
    void set_active(bool active);
    void set_position(int left, int top, int width, int height);
    void set_text(std::wstring text);
    std::wstring get_text();
    HWND handle() const;
    ~Control();
};

class Parent : public Control
{
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
    Label(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height);
};

class Richedit : public Control
{
public:
    Richedit(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height);
};

class Edit : public Control
{
public:
    Edit(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height);
};

class Button : public Control
{
protected:
    static WORD _identifier_generator;
    WORD _identifier = 0;
    Button();

public:
    Button(const Parent *parent, const Font *font, const TCHAR *text, bool capture, int left, int top, int width, int height);
    bool identify(WPARAM wparam) const;
};

class Checkbox : public Button
{
public:
    Checkbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height);
    void set_check(bool check);
    bool get_check() const;
};

class Progress : public Control
{
public:
    Progress(const Parent *parent, unsigned int range, int left, int top, int width, int height);
    void step();
};

class Panel : public Parent
{
public:
    Panel(const Parent *parent, int left, int top, int width, int height);
};

class Groupbox : public Parent
{
public:
    Groupbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height);
};
#pragma endregion

#pragma region Window definition
class Window : public Parent
{
private:
    //Logic
    enum class State
    {
        welcome,
        license,
        location,
        components,
        install,
        finish
    };
    State _state = State::welcome;
    std::wstring _location;
    bool _desktop = true;
    bool _start_menu = true;
    bool _run = true;

    //Controls
    std::unique_ptr<Font> _common_font;
    std::unique_ptr<Font> _big_font;
    std::unique_ptr<Panel> _panel;
    std::unique_ptr<Label> _label_title;
    std::unique_ptr<Label> _label_subtitle;
    std::unique_ptr<Label> _label_text_1;
    std::unique_ptr<Label> _label_text_2;
    std::unique_ptr<Richedit> _richedit_1;
    std::unique_ptr<Groupbox> _browser_1;
    std::unique_ptr<Checkbox> _checkbox_1;
    std::unique_ptr<Checkbox> _checkbox_2;
    std::unique_ptr<Progress> _progress_1;
    std::unique_ptr<Button> _button_previous;
    std::unique_ptr<Button> _button_next;
    std::unique_ptr<Button> _button_cancel;

    //Technical
    WNDCLASSEX _window_class;
    static const int OFFSET = 5;
    static HBRUSH _background_brush;
    static LRESULT CALLBACK _handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam);

    void _initialize(HWND handle);
    void _refresh();

public:
    Window(HINSTANCE hinstance);
    int run();
    ~Window();
};
#pragma endregion

#pragma region Framework implementation
void Control::set_visible(bool visible)
{
    ShowWindow(_handle, visible ? SW_SHOW : SW_HIDE);
}

void Control::set_active(bool active)
{
    EnableWindow(_handle, active);
}

void Control::set_position(int left, int top, int width, int height)
{
    if (SetWindowPos(_handle, NULL, left, top, width, height, SWP_NOOWNERZORDER) == 0)
        throw std::runtime_error("SetWindowPos() failed");
}

void Control::set_text(std::wstring text)
{
    if (!SendMessage(_handle, WM_SETTEXT, 0, reinterpret_cast<LPARAM>(text.c_str())))
        throw std::runtime_error("SendMessage(WM_SETTEXT) failed");
}

std::wstring Control::get_text()
{
    std::wstring text(512, '\0');
    while (true)
    {
        const int len = GetWindowText(_handle, &text[0], static_cast<int>(text.size()));
        if (len < 0) throw std::runtime_error("GetWindowText failed");
        else if (static_cast<size_t>(len) == text.size() - 1) text.resize(2 * text.size());
        else break;
    }
    return text;
}

HWND Control::handle() const
{
    return _handle;
}

Control::~Control()
{
    DestroyWindow(_handle);
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

Label::Label(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | SS_LEFT);
    _handle = CreateWindowEx(WS_EX_TRANSPARENT, TEXT("STATIC"), text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

Richedit::Richedit(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const TCHAR *clas;
    if (LoadLibrary(TEXT("Msftedit.dll")) != NULL) clas = MSFTEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched20.dll")) != NULL) clas = RICHEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched32.dll")) != NULL) clas = RICHEDIT_CLASS;
    else throw std::runtime_error("Could not create Rich Edit");

    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | ES_SUNKEN | ES_AUTOHSCROLL | ES_AUTOVSCROLL | ES_MULTILINE | ES_READONLY);
    _handle = CreateWindowEx(0, clas, text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

Edit::Edit(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | SS_LEFT);
    _handle = CreateWindowEx(0, TEXT("EDIT"), text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

WORD Button::_identifier_generator = 0;

Button::Button() { }

Button::Button(const Parent *parent, const Font *font, const TCHAR *text, bool capture, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_CENTER | BS_TEXT | BS_VCENTER | (capture ? BS_DEFPUSHBUTTON : 0));
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    _identifier = _identifier_generator++;
}

bool Button::identify(WPARAM wparam) const
{
    return LOWORD(wparam) == _identifier;
}

Checkbox::Checkbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, WS_VISIBLE | WS_CHILD |
        BS_CENTER | BS_TEXT | BS_VCENTER, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    _identifier = _identifier_generator++;
}

void Checkbox::set_check(bool check)
{
    const UINT message = static_cast<UINT>(check ? BST_CHECKED : BST_UNCHECKED);
    SendMessage(_handle, message, 0, 0);
}

bool Checkbox::get_check() const
{
    return SendMessage(_handle, BM_GETCHECK, 0, 0) == BST_CHECKED;
}

Progress::Progress(const Parent *parent, unsigned int range, int left, int top, int width, int height)
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

Panel::Panel(const Parent *parent, int left, int top, int width, int height)
{
    _handle = CreateWindowEx(0, TEXT("STATIC"), TEXT(""),
        WS_VISIBLE | WS_CHILD | SS_GRAYFRAME, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
}

Groupbox::Groupbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_GROUPBOX);
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}
#pragma endregion

#pragma region Window implementation
HBRUSH Window::_background_brush = NULL;

LRESULT CALLBACK Window::_handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam)
{
    switch (message)
    {
    case WM_CREATE:
    {
        _background_brush = CreateSolidBrush(RGB(240, 240, 240));
        try
        {
            Window *window = static_cast<Window*>((reinterpret_cast<CREATESTRUCT*>(lparam))->lpCreateParams);
            window->_initialize(handle);
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
        FillRect(hdc, &rect, _background_brush);
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
    const TCHAR *name = TEXT("INSTALLER");
    const TCHAR *caption = TEXT("Installer");
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
    const DWORD style = static_cast<DWORD>(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE);
    _handle = CreateWindowEx(0, name, caption, style, CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, hinstance, this);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx failed");
}

void Window::_initialize(HWND handle)
{
    _handle = handle;
    RECT rect;
    GetClientRect(_handle, &rect);
    const int width = rect.right - rect.left;
    const int height = rect.bottom - rect.top;

    //Create fonts
    _common_font = std::unique_ptr<Font>(new Font(12, false, false));
    _big_font = std::unique_ptr<Font>(new Font(20, true, false));

    //Create common controls
    _panel = std::unique_ptr<Panel>(new Panel(this, -OFFSET, -OFFSET, width + 2 * OFFSET, height - 60 + OFFSET));
    _label_title = std::unique_ptr<Label>(new Label(_panel.get(), _big_font.get(), TEXT(""), 30 + OFFSET, 30 + OFFSET, width - 60, 30));
    _label_subtitle = std::unique_ptr<Label>(new Label(_panel.get(), _common_font.get(), TEXT(""), 30 + OFFSET, 60 + OFFSET, width - 60, 30));
    _button_previous = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Previous"), false, width - 305 + OFFSET, height - 45 + OFFSET, 90, 30));
    _button_next = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT(""), true, width - 210 + OFFSET, height - 45 + OFFSET, 90, 30));
    _button_cancel = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Cancel"), false, width - 105 + OFFSET, height - 45 + OFFSET, 90, 30));

    //Create control pull
    _label_title = std::unique_ptr<Label>(new Label(_panel.get(), _big_font.get(), TEXT(""), 30 + OFFSET, 30 + OFFSET, width - 60, 30));

    //Arrange
    _state = State::welcome;
    _refresh();
}

void Window::_refresh()
{
    RECT rect;
    GetClientRect(_handle, &rect);
    const int width = rect.right - rect.left;
    const int height = rect.bottom - rect.top;

    switch (_state)
    {
    case State::welcome:
        _label_title->set_text(L"Welcome to " DEV_NAME_VERSION " Setup");
        _label_subtitle->set_text(L"Setup will guide you through the installation of " DEV_NAME_VERSION ".");
        _button_previous->set_active(false);
        _button_next->set_text(L"Next >");
        break;
    case State::license:
        _label_title->set_text(L"License Agreement");
        _label_subtitle->set_text(L"Please review the license terms before installing " DEV_NAME_VERSION ".");
        _button_next->set_text(L"I Agree");
        break;
    case State::location:
        _label_title->set_text(L"Chose Install Location");
        _label_subtitle->set_text(L"Chose the folder in which to install " DEV_NAME_VERSION ".");
        _button_next->set_text(L"Next >");
        break;
    case State::components:
        _label_title->set_text(L"Chose Components");
        _label_subtitle->set_text(L"Chose which features of " DEV_NAME_VERSION " you want to install.");
        _button_next->set_text(L"Next >");
        break;
    case State::install:
        _label_title->set_text(L"Installing");
        _label_subtitle->set_text(L"Please wait while " DEV_NAME_VERSION " is being installed.");
        _button_next->set_text(L"Next >");
        break;
    case State::finish:
        _label_title->set_text(L"Completing " DEV_NAME_VERSION " Setup");
        _label_subtitle->set_text(L"" DEV_NAME_VERSION " has been installed on your computer.");
        _button_next->set_text(L"Finish");
        break;
    }
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
#pragma endregion

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

int WINAPI WinMain(_In_ HINSTANCE hinstance, _In_opt_ HINSTANCE, _In_ PSTR, _In_ int)
{
    return _main(hinstance);
}
#pragma endregion