#include <Windows.h>
#include <CommCtrl.h>
#include <RichEdit.h>
#include <shlobj_core.h>
#include <string>
#include <sstream>
#include <iostream>
#include <iomanip>
#include <stdexcept>
#include <functional>
#include <thread>

#define DEV_STRING2(s) #s
#define DEV_STRING(s) DEV_STRING2(s)
#define DEV_NAME DEV_STRING(DEVTEMPLATE_NAME)
#define DEV_NAME_VERSION DEV_STRING(DEVTEMPLATE_NAME) " " DEV_STRING(DEVTEMPLATE_MAJOR) "." DEV_STRING(DEVTEMPLATE_MINOR) "." DEV_STRING(DEVTEMPLATE_PATCH)

#pragma region Framework definitions
typedef std::basic_string<TCHAR> tstring;

class Control
{
protected:
    HWND _handle = NULL;

public:
    void set_visible(bool visible);
    void set_active(bool active);
    void set_position(int left, int top, int width, int height);
    void set_text(const tstring &text);
    tstring get_text();
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
    Progress(const Parent *parent, int left, int top, int width, int height);
    void set_range(unsigned int range);
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

class Util
{
public:
    template <class T> struct ObjectGuard { T* r; ObjectGuard() : r(nullptr) {} ~ObjectGuard() { if (r != nullptr) r->Release(); } };
    struct FileGuard { HANDLE r; FileGuard(HANDLE r) : r(r) {} ~FileGuard() { CloseHandle(r); } };
    struct RegistryGuard { HKEY r; RegistryGuard(HKEY r) : r(r) {} ~RegistryGuard() { RegCloseKey(r); } };
    struct FindGuard { HANDLE r; FindGuard(HANDLE r) : r(r) {} ~FindGuard() { FindClose(r); } };
    struct MemoryGuard { HLOCAL r; MemoryGuard(HLOCAL r) : r(r) {} ~MemoryGuard() { LocalFree(r); } };
    
    static void sanitize(tstring* directory);
    static void pop_slash(tstring *directory);
    static void push_slash(tstring* directory);
    static void create_shortcut(const tstring& target_path, const tstring& shortcut_path, const tstring& description);
    static bool dialog_directory(tstring* directory, const tstring& description);
    static bool dialog_close();
    static void dialog_error(const char *error);
    static tstring get_executable_path();
    static tstring get_executable_directory();
    static tstring get_default_directory(HINSTANCE hinstance);
    static std::wstring string_to_wstring(const std::string& string);
    static std::string wstring_to_string(const std::wstring& string);
    static uint64_t get_available_space();
    static tstring get_space_string(uint64_t space, bool base1024);
    static tstring get_license();
    static void copy(HANDLE handle, HANDLE whandle, uint64_t size);
    static void create(const tstring& path, bool last_is_directory);
};

class Installer
{
public:
    //Structures
    struct FileHeader
    {
        uint64_t relative_path_size;
        uint64_t file_size;
    };
    struct BackHeader
    {
        uint64_t payload_begin;
        uint64_t payload_size;
        uint32_t files_count;
        uint32_t flags;
        unsigned char signature[8];

        static const uint32_t flag_uninstaller = 1;
        static const uint32_t flag_desktop_shortcut = 2;
        static const uint32_t flag_menu_shortcut = 4;
        static const uint32_t flag_add_to_path = 8;
        static const uint32_t flag_install_for_all = 16;
        static const unsigned char right_signature[8];
    };
    #ifdef _DEBUG
    static_assert(sizeof(FileHeader) == 16, "sizeof(FileHeader) != 16");
    static_assert(sizeof(BackHeader) == 32, "sizeof(BackHeader) != 32");
    volatile static const unsigned char debug_data[];
    #endif

    //Options
    tstring directory;
    bool desktop_shortcut = true;
    bool menu_shortcut = true;
    bool add_to_path = true;
    bool install_for_all = true;

    //Technical
    HANDLE handle = INVALID_HANDLE_VALUE;
    uint64_t payload_begin;
    uint64_t payload_size;
    uint32_t files_count;
    bool is_uninstaller;

    Installer(HINSTANCE hinstance);
    ~Installer();

    //Install
    void install_files(std::function<void(const tstring&)> callback) const;
    void install_self() const;
    void install_registry() const;
    void install_desktop_shortcut() const;
    void install_menu_icon() const;
    void install_path() const;
    void run_application() const;

    //Uninstall
    void uninstall_files(std::function<void(const tstring&)> callback) const;
    static void uninstall_self();
    void uninstall_registry() const;
    void uninstall_desktop_shortcut() const;
    void uninstall_menu_icon() const;
    void uninstall_path() const;
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
        directory,
        components,
        install,
        finish,

        uninstall_welcome,
        uninstall_uninstall,
        uninstall_finish
    };
    State _state;
    bool _run_application = true;

    //Unique controls
    std::unique_ptr<Font> _common_font;
    std::unique_ptr<Font> _license_font;
    std::unique_ptr<Font> _big_font;
    std::unique_ptr<Panel> _panel;
    std::unique_ptr<Label> _label_title;
    std::unique_ptr<Label> _label_subtitle;
    std::unique_ptr<Richedit> _license_richedit;
    std::unique_ptr<Groupbox> _groupbox_directory;
    std::unique_ptr<Edit> _edit_directory;
    std::unique_ptr<Button> _button_browse;
    std::unique_ptr<Progress> _progress;
    std::unique_ptr<Button> _button_previous;
    std::unique_ptr<Button> _button_next;
    std::unique_ptr<Button> _button_cancel;

    //Control pool
    std::unique_ptr<Label> _label_1;
    std::unique_ptr<Label> _label_2;
    std::unique_ptr<Checkbox> _checkbox_1;
    std::unique_ptr<Checkbox> _checkbox_2;
    std::unique_ptr<Checkbox> _checkbox_3;
    std::unique_ptr<Checkbox> _checkbox_4;

    //Technical
    Installer *_installer;
    std::thread _thread;
    WNDCLASSEX _window_class;
    HBRUSH _background_brush;
    static const int OFFSET = 5;

    static LRESULT CALLBACK _handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam);
    void _initialize(HWND handle);
    void _refresh();

    void _button_browse_handler();
    void _button_previous_handler();
    void _button_next_handler();
    void _button_cancel_handler();
    void _checkbox_1_handler();
    void _checkbox_2_handler();
    void _checkbox_3_handler();
    void _checkbox_4_handler();
    void _close_handler();

public:
    static Window* static_window;
    static bool static_block_commands;
    Window(HINSTANCE hinstance, Installer *installer);
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

void Control::set_text(const tstring &text)
{
    Window::static_block_commands = true;
    LRESULT result = SendMessage(_handle, WM_SETTEXT, 0, reinterpret_cast<LPARAM>(text.c_str()));
    Window::static_block_commands = false;
    if (!result) throw std::runtime_error("SendMessage(WM_SETTEXT) failed");
}

std::wstring Control::get_text()
{
    std::wstring text(512, '\0');
    while (true)
    {
        const int len = GetWindowText(_handle, &text[0], static_cast<int>(text.size()));
        if (len < 0) throw std::runtime_error("GetWindowText() failed");
        else if (static_cast<size_t>(len) == text.size() - 1) text.resize(2 * text.size());
        else { text.resize(static_cast<size_t>(len)); break; };
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
    if (_handle == NULL) throw std::runtime_error("CreateFontIndirect() failed");
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

    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | ES_SUNKEN | ES_MULTILINE | ES_READONLY);
    _handle = CreateWindowEx(0, clas, text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    SendMessage(_handle, EM_SHOWSCROLLBAR, SB_VERT, TRUE);
}

Edit::Edit(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const TCHAR* clas;
    if (LoadLibrary(TEXT("Msftedit.dll")) != NULL) clas = MSFTEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched20.dll")) != NULL) clas = RICHEDIT_CLASS;
    else if (LoadLibrary(TEXT("Riched32.dll")) != NULL) clas = RICHEDIT_CLASS;
    else throw std::runtime_error("Could not create Rich Edit");

    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | ES_SUNKEN);
    _handle = CreateWindowEx(0, clas, text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
    SendMessage(_handle, EM_SETEVENTMASK, 0, ENM_CHANGE);
}

WORD Button::_identifier_generator = 0;

Button::Button() { }

Button::Button(const Parent *parent, const Font *font, const TCHAR *text, bool capture, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_CENTER | BS_TEXT | BS_VCENTER | (capture ? BS_DEFPUSHBUTTON : 0));
    _identifier = _identifier_generator;
    _identifier_generator++;
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, style, left, top, width, height, parent->handle(), reinterpret_cast<HMENU>(_identifier), NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

bool Button::identify(WPARAM wparam) const
{
    return LOWORD(wparam) == _identifier;
}

Checkbox::Checkbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_CHECKBOX);
    _identifier = _identifier_generator;
    _identifier_generator++;
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, style, left, top, width, height, parent->handle(), reinterpret_cast<HMENU>(_identifier), GetModuleHandle(NULL), NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

void Checkbox::set_check(bool check)
{
    const UINT message = static_cast<UINT>(check ? BST_CHECKED : BST_UNCHECKED);
    SendMessage(_handle, BM_SETCHECK, message, 0);
}

bool Checkbox::get_check() const
{
    return SendMessage(_handle, BM_GETCHECK, 0, 0) == BST_CHECKED;
}

Progress::Progress(const Parent *parent, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_CENTER | BS_TEXT | BS_VCENTER);
    _handle = CreateWindowEx(0, PROGRESS_CLASS, TEXT("progress"), style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, PBM_SETSTEP, (WPARAM)1, 0);
}

void Progress::set_range(unsigned int range)
{
    SendMessage(_handle, PBM_SETRANGE, 0, MAKELPARAM(0, range));
}

void Progress::step()
{
    SendMessage(_handle, PBM_STEPIT, 0, 0);
}

Panel::Panel(const Parent *parent, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | SS_GRAYFRAME);
    _handle = CreateWindowEx(0, TEXT("STATIC"), TEXT(""), style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
}

Groupbox::Groupbox(const Parent *parent, const Font *font, const TCHAR *text, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_GROUPBOX);
    _handle = CreateWindowEx(0, TEXT("BUTTON"), text, style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, WM_SETFONT, (WPARAM)font->handle(), FALSE);
}

void Util::sanitize(tstring* directory)
{
    size_t i;
    for (i = 0;
        i < directory->size() && ((*directory)[i] == ' ' || (*directory)[i] == '\t' || (*directory)[i] == '\r' || (*directory)[i] == '\n');
        i++) {}
    directory->erase(directory->begin(), directory->begin() + static_cast<int64_t>(i));
    for (;
        !directory->empty() && (directory->back() == ' ' || directory->back() == '\t' || directory->back() == '\r' || directory->back() == '\n');
        directory->pop_back()) {}
    for (i = 0; i < directory->size(); i++) { if ((*directory)[i] == '/') (*directory)[i] = '\\'; }
    for (i = 0; i+1 < directory->size();) { if ((*directory)[i] == '\\' && (*directory)[i+1] == '\\') directory->erase(i); else i++; }
}

void Util::pop_slash(tstring* directory)
{
    if (directory->empty()) throw std::runtime_error("Cannot find parent directory");
    if (directory->back() == '/' || directory->back() == '\\') directory->pop_back();
    size_t slash = directory->rfind('/');
    size_t backslash = directory->rfind('\\');
    size_t separator;
    if (slash == tstring::npos && backslash == tstring::npos) throw std::runtime_error("Cannot find parent directory");
    else if (slash == tstring::npos && backslash != tstring::npos) separator = backslash;
    else if (slash != tstring::npos && backslash == tstring::npos) separator = slash;
    else separator = (slash > backslash) ? slash : backslash;
    directory->resize(separator + 1);
}

void Util::push_slash(tstring* directory)
{
    if (directory->empty() || (directory->back() != '/' && directory->back() != '\\')) directory->push_back('\\');
}

void Util::create_shortcut(const tstring& target_path, const tstring& link_path, const tstring& description)
{
    ObjectGuard<IShellLink> shell;
    if (!SUCCEEDED(CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&shell.r))))
        throw std::runtime_error("CoCreateInstance() failed");

    if (!SUCCEEDED(shell.r->SetPath(target_path.c_str())))
        throw std::runtime_error("IShellLink::SetPath() failed");

    if (!SUCCEEDED(shell.r->SetDescription(description.c_str())))
        throw std::runtime_error("IShellLink::SetDescription() failed");

    ObjectGuard<IPersistFile> file;
    if (!SUCCEEDED(shell.r->QueryInterface(IID_PPV_ARGS(&file.r))))
        throw std::runtime_error("IShellLink::QueryInterface() failed");

    if (!SUCCEEDED(file.r->Save(link_path.c_str(), TRUE)))
        throw std::runtime_error("IPersistFile::Save() failed");
}

bool Util::dialog_directory(tstring* directory, const tstring& description)
{
    ObjectGuard<IShellItem> shell;
    if (!SUCCEEDED(SHCreateItemFromParsingName(directory->c_str(), NULL, IID_PPV_ARGS(&shell.r))))
        throw std::runtime_error("SHCreateItemFromParsingName() failed");

    ObjectGuard<IFileDialog> dialog;
    if (!SUCCEEDED(CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog.r))))
        throw std::runtime_error("CoCreateInstance() failed");

    DWORD flags;
    if (!SUCCEEDED(dialog.r->GetOptions(&flags)))
        throw std::runtime_error("IFileDialog::GetOptions() failed");

    if (!SUCCEEDED(dialog.r->SetOptions(flags | FOS_PICKFOLDERS)))
        throw std::runtime_error("IFileDialog::SetOptions() failed");

    if (!SUCCEEDED(dialog.r->SetTitle(description.c_str())))
        throw std::runtime_error("IFileDialog::SetTitle() failed");

    if (!SUCCEEDED(dialog.r->SetDefaultFolder(shell.r)) || !SUCCEEDED(dialog.r->SetFolder(shell.r)))
        throw std::runtime_error("IFileDialog::SetDefaultFolder() failed");

    if (!SUCCEEDED(dialog.r->Show(NULL))) return false;

    ObjectGuard<IShellItem> result;
    if (!SUCCEEDED(dialog.r->GetResult(&result.r))) return false;

    PWSTR selected;
    if (!SUCCEEDED(result.r->GetDisplayName(SIGDN_FILESYSPATH, &selected))) return false;
    *directory = selected;
    CoTaskMemFree(selected);

    push_slash(directory);
    return true;
}

bool Util::dialog_close()
{
    const int reply = MessageBox(NULL,
        TEXT("Are you sure you want to quit " DEV_NAME_VERSION " Setup"),
        TEXT("" DEV_NAME_VERSION " Setup"),
        MB_ICONEXCLAMATION | MB_YESNO);
    return reply == IDYES;
}

void Util::dialog_error(const char* error)
{
    const TCHAR* text;
    #if UNICODE
        std::wstring wtext = Util::string_to_wstring(error);
        text = wtext.c_str();
    #else
        text = error;
    #endif
    MessageBox(NULL,
        text,
        TEXT("Error"),
        MB_ICONERROR | MB_OK);
    std::cerr << error << std::endl;
}

tstring Util::get_executable_path()
{
    tstring path(256, '\0');
    while (true)
    {
        DWORD length = GetModuleFileName(NULL, &path[0], static_cast<DWORD>(path.size() + 1));
        if (length == 0) throw std::runtime_error("GetModuleFileName() failed");
        else if (length == path.size()) path.resize(path.size() * 2);
        else { path.resize(length); break; }
    }
    return path;
}

tstring Util::get_executable_directory()
{
    tstring directory = get_executable_path();
    pop_slash(&directory);
    return directory;
}

tstring Util::get_default_directory(HINSTANCE hinstance)
{
    int default_directory_id = CSIDL_PROGRAM_FILES;
    const bool false_true[] = { false, true };
    if (false_true[(sizeof(void*) == 8) ? 1 : 0]) //Suppresses constexpr warning in MSVS
    {
        BOOL wow64 = false;
        if (IsWow64Process(hinstance, &wow64) && wow64) default_directory_id = CSIDL_PROGRAM_FILESX86;
    }
    TCHAR default_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, default_directory_id, NULL, 0, default_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring default_directory = default_directory_array;
    if (!default_directory.empty() && default_directory.back()) default_directory.push_back('\\');
    default_directory += TEXT(DEV_NAME "\\");
    return default_directory;
}

std::wstring Util::string_to_wstring(const std::string& string)
{
    int length = MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, string.c_str(), -1, nullptr, 0);
    if (length <= 0) throw std::runtime_error("MultiByteToWideChar() failed");
    std::wstring result(static_cast<size_t>(length) - 1, '\0');
    MultiByteToWideChar(CP_ACP, MB_ERR_INVALID_CHARS, string.c_str(), -1, &result[0], length);
    return result;
}

std::string Util::wstring_to_string(const std::wstring& string)
{
    int length = WideCharToMultiByte(CP_ACP, MB_ERR_INVALID_CHARS, string.c_str(), -1, nullptr, 0, nullptr, nullptr);
    if (length <= 0) throw std::runtime_error("MultiByteToWideChar() failed");
    std::string result(static_cast<size_t>(length) - 1, '\0');
    WideCharToMultiByte(CP_ACP, MB_ERR_INVALID_CHARS, string.c_str(), -1, &result[0], length, nullptr, nullptr);
    return result;
}

uint64_t Util::get_available_space()
{
    TCHAR directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, CSIDL_PROGRAM_FILES, NULL, 0, directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring directory = directory_array;
    directory.resize(directory.find('\\') + 1);

    DWORD sectors_per_cluser, bytes_per_sector, free_clusters, total_clusters;
    if (GetDiskFreeSpace(directory.c_str(), &sectors_per_cluser, &bytes_per_sector, &free_clusters, &total_clusters) == 0)
        throw std::runtime_error("GetDiskFreeSpace() failed");
    return static_cast<uint64_t>(sectors_per_cluser) * static_cast<uint64_t>(bytes_per_sector) * static_cast<uint64_t>(free_clusters);
}

tstring Util::get_space_string(uint64_t space, bool base1024)
{
    uint64_t unit;
    const TCHAR* unit_name;
    if (base1024)
    {
        if (space < 1024ull) { unit = 1; unit_name = TEXT("B"); }
        else if (space < 1024ull*1024ull) { unit = 1024ull; unit_name = TEXT("KiB"); }
        else if (space < 1024ull*1024ull*1024ull) { unit = 1024ull*1024ull; unit_name = TEXT("MiB"); }
        else if (space < 1024ull*1024ull*1024ull*1024ull) { unit = 1024ull*1024ull*1024ull; unit_name = TEXT("GiB"); }
        else { unit = 1024ull*1024ull*1024ull*1024ull; unit_name = TEXT("TiB"); }
    }
    else
    {
        if (space < 1000ull) { unit = 1; unit_name = TEXT("B"); }
        else if (space < 1000ull*1000ull) { unit = 1000ull; unit_name = TEXT("KB"); }
        else if (space < 1000ull*1000ull*1000ull) { unit = 1000ull*1000ull; unit_name = TEXT("MB"); }
        else if (space < 1000ull*1000ull*1000ull*1000ull) { unit = 1000ull*1000ull*1000ull; unit_name = TEXT("GB"); }
        else { unit = 1000ull*1000ull*1000ull*1000ull; unit_name = TEXT("TB"); }
    }
    double number = static_cast<double>(space) / static_cast<double>(unit);
    std::basic_ostringstream<TCHAR> stream;
    stream << std::setprecision(2) << number << " " << unit_name;
    return stream.str();
}

tstring Util::get_license()
{
    HMODULE module = GetModuleHandle(NULL);
    HRSRC resource = FindResource(module, MAKEINTRESOURCE(1001), L"LICENSE");
    if (resource == NULL) throw std::runtime_error("FindResource() failed");
    HGLOBAL global = LoadResource(module, resource);
    if (global == NULL) throw std::runtime_error("LoadResource() failed");
    const char* license = static_cast<const char*>(LockResource(global));
    if (license == nullptr) throw std::runtime_error("LockResource() failed");
    #ifdef UNICODE
        return string_to_wstring(license);
    #else
        return license;
    #endif
}

void Util::copy(HANDLE handle, HANDLE whandle, uint64_t size)
{
    while (size > 0)
    {
        DWORD read;
        char buffer[4096];
        DWORD to_read = static_cast<DWORD>((size > sizeof(buffer)) ? sizeof(buffer) : size);
        if (!ReadFile(handle, buffer, to_read, &read, nullptr) || read != to_read) throw std::runtime_error("ReadFile() failed");
        if (!WriteFile(whandle, buffer, to_read, &read, nullptr) || read != to_read) throw std::runtime_error("WriteFile() failed");
        size -= to_read;
    }
}

void Util::create(const tstring& path, bool last_is_directory)
{
    DWORD flags = GetFileAttributes(path.c_str());
    bool exists = flags != INVALID_FILE_ATTRIBUTES;
    bool is_directory = exists && (flags & FILE_ATTRIBUTE_DIRECTORY) != 0;
    if (exists && (last_is_directory ^ is_directory)) throw std::runtime_error("Unable to create directory");
    if (exists) return;
    tstring path_copy = path;
    pop_slash(&path_copy);
    create(path_copy, true);
    if (last_is_directory && !CreateDirectory(path.c_str(), nullptr)) throw std::runtime_error("Unable to create directory");
}

const unsigned char Installer::BackHeader::right_signature[8] = { 137, 20, 14, 78, 66, 7, 48, 183 };

#ifdef _DEBUG
volatile const unsigned char Installer::debug_data[] = {
    14, 0, 0, 0, 0, 0, 0, 0, //uint64_t name_size = 14
    5, 0, 0, 0, 0, 0, 0, 0,//uint64_t file_size = 5
    'd', 0, 'a', 0, 't', 0, 'a', 0, '/', 0, 'd', 0, 'e', 0, 'b', 0, 'u', 0, 'g', 0, '.', 0, 't', 0, 'x', 0, 't', 0, //data/debug.txt
    'd', 'e', 'b', 'u', 'g', //debug
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, //uint64_t payload_begin = -1
    5, 0, 0, 0, 0, 0, 0, 0, //uint64_t payload_size = 5
    1, 0, 0, 0, //uint32_t files_count = 1
    0xfe, 0xff, 0xff, 0xff, //uint32_t flags = -2
    138, 20, 14, 78, 66, 7, 48, 183 //right_installer_signature + 1
};
#endif

Installer::Installer(HINSTANCE hinstance)
{
    tstring executable_path = Util::get_executable_path();
    Util::FileGuard ghandle(CreateFile(executable_path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL));
    if (ghandle.r == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
    DWORD self_size = GetFileSize(ghandle.r, nullptr);
    BackHeader header;
    DWORD read;

    #ifdef _DEBUG
    
    unsigned char right_signature[sizeof(BackHeader::right_signature)];
    memcpy(right_signature, BackHeader::right_signature, sizeof(right_signature));
    right_signature[0]++;
    unsigned int match = 0;
    for (payload_begin = 0; payload_begin < self_size && match != sizeof(right_signature); payload_begin++)
    {
        unsigned char c;
        if (!ReadFile(ghandle.r, &c, 1, &read, nullptr) || read != 1) throw std::runtime_error("ReadFile() failed");
        if (c == right_signature[match]) match++; else match = 0;
    }
    if (match != sizeof(right_signature)) throw std::runtime_error("Debug signature not found");
    payload_begin -= sizeof(BackHeader);
    SetFilePointer(ghandle.r, static_cast<LONG>(payload_begin), nullptr, FILE_BEGIN);
    if (!ReadFile(ghandle.r, &header, sizeof(header), &read, nullptr) || read != sizeof(header)) throw std::runtime_error("ReadFile() failed");
    payload_begin -= (sizeof(debug_data) - sizeof(BackHeader));
    
    #else
    
    SetFilePointer(ghandle.r, static_cast<LONG>(self_size - sizeof(header)), nullptr, FILE_BEGIN);
    if (!ReadFile(ghandle.r, &header, sizeof(header), &read, nullptr) || read != sizeof(header)) throw std::runtime_error("ReadFile() failed");
    if (memcmp(header.signature, BackHeader::right_signature, sizeof(header.signature)) != 0)
        throw std::runtime_error("Invalid signature");
    payload_begin = header.payload_begin;
    
    #endif

    payload_size = header.payload_size;
    files_count = header.files_count;
    is_uninstaller = (header.flags & BackHeader::flag_uninstaller) != 0;
    if (is_uninstaller)
    {
        directory = Util::get_executable_directory();
        desktop_shortcut = (header.flags & BackHeader::flag_desktop_shortcut) != 0;
        menu_shortcut = (header.flags & BackHeader::flag_menu_shortcut) != 0;
        add_to_path = (header.flags & BackHeader::flag_add_to_path) != 0;
        install_for_all = (header.flags & BackHeader::flag_install_for_all) != 0;
    }
    else
    {
        directory = Util::get_default_directory(hinstance);
    }
    handle = ghandle.r;
    ghandle.r = INVALID_HANDLE_VALUE;
}

Installer::~Installer()
{
    if (handle != INVALID_HANDLE_VALUE) CloseHandle(handle);
}

void Installer::install_files(std::function<void(const tstring&)> callback) const
{
    SetFilePointer(handle, static_cast<LONG>(payload_begin), nullptr, FILE_BEGIN);

    //Process
    for (uint32_t i = 0; i < files_count; i++)
    {
        //Read header
        FileHeader file_header;
        DWORD read;
        if (!ReadFile(handle, &file_header, sizeof(file_header), &read, nullptr) || read != sizeof(file_header))
            throw std::runtime_error("ReadFile() failed");

        //Read name
        std::wstring relative_path(file_header.relative_path_size, '\0');
        if (!ReadFile(handle, &relative_path[0], static_cast<DWORD>(relative_path.size() * sizeof(wchar_t)), &read, nullptr)
        || read != relative_path.size() * sizeof(wchar_t)) throw std::runtime_error("ReadFile() failed");
        
        #ifdef UNICODE
        callback(L"Copying " + relative_path);
        #else
        callback("Copying " + Installer::wstring_to_string(relative_path));
        #endif

        //Copy file
        std::wstring absolute_path = directory + relative_path;
        Util::create(absolute_path, false);
        Util::FileGuard whandle(CreateFile(absolute_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL));
        if (whandle.r == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
        Util::copy(handle, whandle.r, file_header.file_size);
    }
}

void Installer::install_self() const
{
    SetFilePointer(handle, 0, nullptr, FILE_BEGIN);

    //Copy original file
    tstring absolute_path = directory + TEXT("uninstall.exe");
    Util::FileGuard whandle(CreateFile(absolute_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL));
    if (whandle.r == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
    Util::copy(handle, whandle.r, payload_begin);

    //Copy file headers
    for (uint32_t i = 0; i < files_count; i++)
    {
        //Copy header
        FileHeader file_header;
        DWORD read;
        if (!ReadFile(handle, &file_header, sizeof(file_header), &read, nullptr) || read != sizeof(file_header))
            throw std::runtime_error("ReadFile() failed");
        if (!WriteFile(whandle.r, &file_header, sizeof(file_header), &read, nullptr) || read != sizeof(file_header))
            throw std::runtime_error("WriteFile() failed");

        //Copy name
        Util::copy(handle, whandle.r, file_header.relative_path_size * sizeof(wchar_t));
    }

    //Copy signature
    BackHeader header;
    header.payload_begin = payload_begin;
    header.payload_size = payload_size;
    header.files_count = files_count;
    header.flags = BackHeader::flag_uninstaller;
    if (desktop_shortcut) header.flags |= BackHeader::flag_desktop_shortcut;
    if (menu_shortcut) header.flags |= BackHeader::flag_menu_shortcut;
    if (add_to_path) header.flags |= BackHeader::flag_add_to_path;
    if (install_for_all) header.flags |= BackHeader::flag_install_for_all;
    DWORD written;
    if (!WriteFile(whandle.r, &header, sizeof(header), &written, nullptr) || written != sizeof(header))
        throw std::runtime_error("WriteFile() failed");
}

void Installer::install_registry() const
{
    HKEY key = install_for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const TCHAR* subkey = TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\" DEV_NAME);
    std::runtime_error e("RegSetKeyValue() failed");
    tstring s;
    DWORD d;

    //Strings
    s = directory + TEXT(DEV_STRING(DEVTEMPLATE_FILE_NAME) ".exe");
    if (RegSetKeyValue(key, subkey, TEXT("DisplayIcon"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT(DEV_NAME);
    if (RegSetKeyValue(key, subkey, TEXT("DisplayName"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT(DEV_STRING(DEVTEMPLATE_MAJOR) "." DEV_STRING(DEVTEMPLATE_MINOR));
    if (RegSetKeyValue(key, subkey, TEXT("DisplayVersion"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT(DEV_STRING(DEVTEMPLATE_MAJOR));
    if (RegSetKeyValue(key, subkey, TEXT("MajorVersion"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT(DEV_STRING(DEVTEMPLATE_MINOR));
    if (RegSetKeyValue(key, subkey, TEXT("MinorVersion"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT(DEV_STRING(DEVTEMPLATE_AUTHOR));
    if (RegSetKeyValue(key, subkey, TEXT("Publisher"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT("\"") + directory + TEXT("uninstall.exe\" --uninstall");
    if (RegSetKeyValue(key, subkey, TEXT("UninstallString"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    s = TEXT("\"") + directory + TEXT("uninstall.exe\" --quiet-uninstall");
    if (RegSetKeyValue(key, subkey, TEXT("QuietUninstallString"), REG_SZ, s.c_str(), static_cast<DWORD>(s.size() * sizeof(TCHAR))) != ERROR_SUCCESS) throw e;
    
    //Numbers
    d = static_cast<DWORD>(payload_size / static_cast<uint64_t>(1000)); //Assuming kilobytes
    if (RegSetKeyValue(key, subkey, TEXT("EstimatedSize"), REG_DWORD, reinterpret_cast<const TCHAR*>(&d), sizeof(d)) != ERROR_SUCCESS) throw e;
    d = 1;
    if (RegSetKeyValue(key, subkey, TEXT("NoModify"), REG_DWORD, reinterpret_cast<const TCHAR*>(&d), sizeof(d)) != ERROR_SUCCESS) throw e;
    d = 1;
    if (RegSetKeyValue(key, subkey, TEXT("NoRepair"), REG_DWORD, reinterpret_cast<const TCHAR*>(&d), sizeof(d)) != ERROR_SUCCESS) throw e;
    d = DEVTEMPLATE_MAJOR;
    if (RegSetKeyValue(key, subkey, TEXT("VersionMajor"), REG_DWORD, reinterpret_cast<const TCHAR*>(&d), sizeof(d)) != ERROR_SUCCESS) throw e;
    d = DEVTEMPLATE_MINOR;
    if (RegSetKeyValue(key, subkey, TEXT("VersionMinor"), REG_DWORD, reinterpret_cast<const TCHAR*>(&d), sizeof(d)) != ERROR_SUCCESS) throw e;
}

void Installer::install_desktop_shortcut() const
{
    TCHAR desktop_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, install_for_all ? CSIDL_COMMON_DESKTOPDIRECTORY : CSIDL_DESKTOPDIRECTORY, NULL, 0, desktop_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring desktop_directory = desktop_directory_array;
    Util::push_slash(&desktop_directory);
    Util::create_shortcut(directory + TEXT(DEV_NAME ".exe"), desktop_directory + TEXT(DEV_NAME ".lnk"), TEXT(DEV_STRING(DEVTEMPLATE_DESCRIPTION)));
}

void Installer::install_menu_icon() const
{
    //TODO: refactor and merge with install_desktop_shortcut
    TCHAR menu_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, install_for_all ? CSIDL_COMMON_PROGRAMS : CSIDL_PROGRAMS, NULL, 0, menu_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring menu_directory = menu_directory_array;
    Util::push_slash(&menu_directory);
    Util::create_shortcut(directory + TEXT(DEV_NAME ".exe"), menu_directory + TEXT(DEV_NAME ".lnk"), TEXT(DEV_STRING(DEVTEMPLATE_DESCRIPTION)));
}

void Installer::install_path() const
{
    //Get path
    HKEY key = install_for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const TCHAR* subkey = install_for_all ? TEXT("SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\") : TEXT("Environment\\");
    tstring path;
    DWORD path_size = 0;
    if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, NULL, &path_size) == ERROR_SUCCESS)
    {
        path.resize(path_size / sizeof(TCHAR), '\0');
        if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, &path[0], &path_size) != ERROR_SUCCESS)
            throw std::runtime_error("RegGetValue() failed");
    }

    //Process path
    if (path.find(directory) != tstring::npos) return;
    else if (path.empty()) path = directory;
    else { if (path.back() != ';') path.push_back(';'); path += directory; }

    //Set path
    if (RegSetKeyValue(key, subkey, TEXT("PATH"), REG_SZ, path.c_str(), static_cast<DWORD>(path.size() * sizeof(TCHAR))) != ERROR_SUCCESS)
        throw std::runtime_error("RegSetKeyValue() failed");
}

void Installer::run_application() const
{
    STARTUPINFO startup_info = { 0 };
    startup_info.cb = sizeof(startup_info);
    PROCESS_INFORMATION process_info = { 0 };
    tstring path = directory + TEXT(DEV_NAME ".exe");
    CreateProcess(path.c_str(), nullptr, nullptr, nullptr, false, 0, nullptr, nullptr, &startup_info, &process_info);
    CloseHandle(process_info.hProcess);
    CloseHandle(process_info.hThread);
}

void Installer::uninstall_files(std::function<void(const tstring&)> callback) const
{
    struct Remove
    {
        static void remove(unsigned int depth, std::function<void(const tstring&)> callback, const tstring &directory, size_t absolute_size)
        {
            tstring pattern = directory + TEXT("*");
            WIN32_FIND_DATA find;
            Util::FindGuard handle(FindFirstFile(pattern.c_str(), &find));
            if (handle.r == INVALID_HANDLE_VALUE) return;

            while (true)
            {
                bool ignore = false;
                #ifdef UNICODE
                ignore = ignore || wcscmp(find.cFileName, L".") == 0;
                ignore = ignore || wcscmp(find.cFileName, L"..") == 0;
                ignore = ignore || (depth == 0 && wcscmp(find.cFileName, L"uninstall.exe") == 0);
                #else
                ignore = ignore || strcmp(find.cFileName, L".") == 0;
                ignore = ignore || strcmp(find.cFileName, L"..") == 0;
                ignore = ignore || (depth == 0 && strcmp(find.cFileName, "uninstall.exe") == 0);
                #endif
                if (ignore) {}
                else if ((find.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0)
                {
                    tstring path = directory + TEXT("\\") + find.cFileName + TEXT("\\");
                    remove(depth + 1, callback, path, absolute_size);
                    if (!RemoveDirectory(path.c_str())) throw std::runtime_error("RemoveDirectory() failed");
                }
                else
                {
                    tstring path = directory + TEXT("\\") + find.cFileName;
                    if (!DeleteFile(path.c_str())) throw std::runtime_error("DeleteFile() failed");
                    tstring message = TEXT("Removing ") + path.substr(absolute_size);
                    callback(message);
                }
                if (!FindNextFile(handle.r, &find)) break;
            }
        }
    };
    Remove::remove(0, callback, directory, directory.size());
}

void Installer::uninstall_self()
{
    //Get temp folder
    tstring temp(256, '\0');
    while (true)
    {
        DWORD length = GetTempPath(static_cast<DWORD>(temp.size() + 1), &temp[0]);
        if (length == 0) throw std::runtime_error("GetTempPath() failed");
        else if (length == temp.size()) temp.resize(temp.size() * 2);
        else { temp.resize(length); break; }
    }
    if (temp.back() != '\\') temp.push_back('\\');
    temp += TEXT("uninstall.exe");

    //Make copy of ourselves
    tstring self = Util::get_executable_path();
    if (!CopyFile(self.c_str(), temp.c_str(), false)) throw std::runtime_error("CopyFile() failed");

    //Delete the copy when we die
    SECURITY_ATTRIBUTES security_attributes = { 0 };
    security_attributes.nLength = sizeof(security_attributes);
    security_attributes.bInheritHandle = true;
    HANDLE handle = CreateFile(temp.c_str(), 0, FILE_SHARE_READ, &security_attributes, OPEN_EXISTING, FILE_FLAG_DELETE_ON_CLOSE, NULL);
    if (handle == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");

    //Launch copy
    STARTUPINFO startup_info = { 0 };
    PROCESS_INFORMATION process_info = { 0 };
    startup_info.cb = sizeof(startup_info);
    temp += TEXT(" --delete "); temp += self;
    CreateProcess(NULL, &temp[0], NULL, NULL, true, 0, NULL, NULL, &startup_info, &process_info);
    CloseHandle(process_info.hProcess);
    CloseHandle(process_info.hThread);
}

void Installer::uninstall_registry() const
{
    HKEY key = install_for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const TCHAR* subkey = TEXT("Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\" DEV_NAME);
    RegDeleteKey(key, subkey);
    RegDeleteKey(key, subkey);
}

void Installer::uninstall_desktop_shortcut() const
{
    TCHAR desktop_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, install_for_all ? CSIDL_COMMON_DESKTOPDIRECTORY : CSIDL_DESKTOPDIRECTORY, NULL, 0, desktop_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring desktop_directory = desktop_directory_array;
    Util::push_slash(&desktop_directory);
    desktop_directory += TEXT(DEV_NAME ".lnk");
    DeleteFile(desktop_directory.c_str());
}

void Installer::uninstall_menu_icon() const
{
    TCHAR menu_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, install_for_all ? CSIDL_COMMON_PROGRAMS : CSIDL_PROGRAMS, NULL, 0, menu_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring menu_directory = menu_directory_array;
    Util::push_slash(&menu_directory);
    menu_directory += TEXT(DEV_NAME ".lnk");
    DeleteFile(menu_directory.c_str());
}

void Installer::uninstall_path() const
{
    HKEY key = install_for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const TCHAR* subkey = install_for_all ? TEXT("SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\") : TEXT("Environment\\");
    tstring path;
    DWORD path_size = 0;
    if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, NULL, &path_size) != ERROR_SUCCESS) return;
    path.resize(path_size / sizeof(TCHAR), '\0');
    if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, &path[0], &path_size) != ERROR_SUCCESS) return;
    size_t entry = path.find(directory);
    if (entry == tstring::npos) return;
    path.erase(path.begin(), path.begin() + static_cast<int64_t>(directory.size()));
    RegSetKeyValue(key, subkey, TEXT("PATH"), REG_SZ, path.c_str(), static_cast<DWORD>(path.size() * sizeof(TCHAR)));
}
#pragma endregion

#pragma region Window implementation
LRESULT CALLBACK Window::_handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam)
{
    try
    {
        switch (message)
        {
        case WM_CREATE:
        {
            static_window = static_cast<Window*>((reinterpret_cast<CREATESTRUCT*>(lparam))->lpCreateParams);
            static_window->_initialize(handle);
            return 0;
        }
        case WM_COMMAND:
        {
            if (static_block_commands) return 0;
            if (HIWORD(wparam) == BN_CLICKED && static_window->_button_browse->identify(wparam)) static_window->_button_browse_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_button_previous->identify(wparam)) static_window->_button_previous_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_button_next->identify(wparam)) static_window->_button_next_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_button_cancel->identify(wparam)) static_window->_button_cancel_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_checkbox_1->identify(wparam)) static_window->_checkbox_1_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_checkbox_2->identify(wparam)) static_window->_checkbox_2_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_checkbox_3->identify(wparam)) static_window->_checkbox_3_handler();
            else if (HIWORD(wparam) == BN_CLICKED && static_window->_checkbox_4->identify(wparam)) static_window->_checkbox_4_handler();
            else if (HIWORD(wparam) == EN_CHANGE) //TODO: no identifications
            {
                static_window->_installer->directory = static_window->_edit_directory->get_text();
                Util::sanitize(&static_window->_installer->directory);
                Util::push_slash(&static_window->_installer->directory);
            }
            else break;
            return 0;
        }
        case WM_CLOSE:
        {
            static_window->_close_handler();
            return 0;
        }
        case WM_ERASEBKGND:
        {
            HDC hdc = (HDC)(wparam);
            RECT rect;
            GetClientRect(handle, &rect);
            FillRect(hdc, &rect, static_window->_background_brush);
            return 0;
        }
        case WM_CTLCOLORBTN:
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
        }
        return DefWindowProc(handle, message, wparam, lparam);
    }
    catch (const std::exception& e)
    {
        Util::dialog_error(e.what());
        return -1;
    }
}

void Window::_initialize(HWND handle)
{
    _handle = handle;
    _background_brush = CreateSolidBrush(RGB(240, 240, 240));
    tstring license = Util::get_license();

    RECT rect;
    GetClientRect(_handle, &rect);
    const int width = rect.right - rect.left;
    const int height = rect.bottom - rect.top;    

    //Create fonts
    _common_font = std::unique_ptr<Font>(new Font(14, false, false));
    _license_font = std::unique_ptr<Font>(new Font(11, false, false));
    _big_font = std::unique_ptr<Font>(new Font(22, true, false));

    //Unique controls
    _panel = std::unique_ptr<Panel>(new Panel(this, -OFFSET, -OFFSET, width + 2 * OFFSET, height - 60 + OFFSET));
    _label_title = std::unique_ptr<Label>(new Label(this, _big_font.get(), TEXT(""), 30, 30, width - 60, 30));
    _label_subtitle = std::unique_ptr<Label>(new Label(this, _common_font.get(), TEXT(""), 30, 60, width - 60, 30));
    _license_richedit = std::unique_ptr<Richedit>(new Richedit(this, _license_font.get(), license.c_str(), 30, 150, width - 60, height - 300));
    _groupbox_directory = std::unique_ptr<Groupbox>(new Groupbox(this, _license_font.get(), TEXT("Location"), 30, 200, width - 60, 60));
    _edit_directory = std::unique_ptr<Edit>(new Edit(this, _common_font.get(), _installer->directory.c_str(), 45, 215 + 4, width - 190, 30));
    _button_browse = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Browse"), false, width - 135, 215 + 4, 90, 30));
    _progress = std::unique_ptr<Progress>(new Progress(this, 30, 150, width - 60, 30));
    _button_previous = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Previous"), false, width - 305, height - 45, 90, 30));
    _button_next = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT(""), true, width - 210, height - 45, 90, 30));
    _button_cancel = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Cancel"), false, width - 105, height - 45, 90, 30));
    _checkbox_1 = std::unique_ptr<Checkbox>(new Checkbox(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));
    _checkbox_2 = std::unique_ptr<Checkbox>(new Checkbox(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));
    _checkbox_3 = std::unique_ptr<Checkbox>(new Checkbox(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));
    _checkbox_4 = std::unique_ptr<Checkbox>(new Checkbox(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));

    //Shared controls
    _label_1 = std::unique_ptr<Label>(new Label(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));
    _label_2 = std::unique_ptr<Label>(new Label(this, _common_font.get(), TEXT(""), 0, 0, 0, 0));

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

    InvalidateRect(_handle, &rect, true);

    //Unique controls
    _license_richedit->set_visible(false);
    _groupbox_directory->set_visible(false);
    _edit_directory->set_visible(false);
    _button_browse->set_visible(false);
    _progress->set_visible(false);

    //Shared controls
    _label_1->set_visible(false);
    _label_2->set_visible(false);
    _checkbox_1->set_visible(false);
    _checkbox_2->set_visible(false);
    _checkbox_3->set_visible(false);
    _checkbox_4->set_visible(false);

    switch (_state)
    {
    case State::welcome:
        _label_title->set_text(TEXT("Welcome to " DEV_NAME_VERSION " Setup"));
        _label_subtitle->set_text(TEXT("Setup will guide you through the installation of " DEV_NAME_VERSION "."));
        _button_previous->set_active(false);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(true);

        _label_1->set_position(30, 120, width - 60, height - 210);
        _label_1->set_text(TEXT("It is recommended that you close all other applications before staring Setup. "
            "This will make it possible to update relevant system files without having to reboot your computer.\r\n"
            "\r\n"
            "Click Next to continue."));
        _label_1->set_visible(true);
        break;
    case State::license:
        _label_title->set_text(TEXT("License Agreement"));
        _label_subtitle->set_text(TEXT("Please review the license terms before installing " DEV_NAME_VERSION "."));
        _button_previous->set_active(true);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("I Agree"));
        _button_cancel->set_active(true);

        _label_1->set_position(30, 120, width - 60, 30);
        _label_1->set_text(TEXT("Press Page Down to see the rest of the agreement."));
        _label_1->set_visible(true);
        _license_richedit->set_visible(true);
        _label_2->set_position(30, height - 150, width - 60, 60);
        _label_2->set_text(TEXT("If you accept the agreement, click I Accept to continue. You must accept the agreement to install " DEV_NAME_VERSION "."));
        _label_2->set_visible(true);
        break;
    case State::directory:
        _label_title->set_text(TEXT("Choose Install Location"));
        _label_subtitle->set_text(TEXT("Choose the folder in which to install " DEV_NAME_VERSION "."));
        _button_previous->set_active(true);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(true);

        _label_1->set_position(30, 120, width - 60, 60);
        _label_1->set_text(TEXT("Setup will install " DEV_NAME_VERSION " in the following folder. "
            "To install in a different folder, clock browse and select another folder.\r\n"
            "Click Next to continue."));
        _label_1->set_visible(true);
        _groupbox_directory->set_visible(true);
        _edit_directory->set_visible(true);
        _button_browse->set_visible(true);
        _label_2->set_position(30, height - 150, width - 60, 60);
        _label_2->set_text(TEXT("Space required: ") + Util::get_space_string(_installer->payload_size, false) + TEXT("\r\n")
            TEXT("Space available: ") + Util::get_space_string(Util::get_available_space(), false));
        _label_2->set_visible(true);
        break;
    case State::components:
        _label_title->set_text(TEXT("Chose Components"));
        _label_subtitle->set_text(TEXT("Chose which features of " DEV_NAME_VERSION " you want to install."));
        _button_previous->set_active(true);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(true);

        _checkbox_1->set_position(30, 120, width - 60, 30);
        _checkbox_1->set_text(TEXT("Create Shortcut on Desktop"));
        _checkbox_1->set_visible(true);
        _checkbox_1->set_check(_installer->desktop_shortcut);
        _checkbox_2->set_position(30, 180, width - 60, 30);
        _checkbox_2->set_text(TEXT("Create Entry in Start Menu"));
        _checkbox_2->set_visible(true);
        _checkbox_2->set_check(_installer->menu_shortcut);
        _checkbox_3->set_position(30, 240, width - 60, 30);
        _checkbox_3->set_text(TEXT("Add install directory to PATH"));
        _checkbox_3->set_visible(true);
        _checkbox_3->set_check(_installer->add_to_path);
        _checkbox_4->set_position(30, 300, width - 60, 30);
        _checkbox_4->set_text(TEXT("Install for all Users on the Machine"));
        _checkbox_4->set_visible(true);
        _checkbox_4->set_check(_installer->install_for_all);
        break;
    case State::install:
        _label_title->set_text(TEXT("Installing"));
        _label_subtitle->set_text(TEXT("Please wait while " DEV_NAME_VERSION " is being installed."));
        _button_previous->set_active(false);
        _button_next->set_active(false);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(false);

        _label_1->set_position(30, 120, width - 60, 30);
        _label_1->set_text(TEXT("Initializing"));
        _label_1->set_visible(true);
        _progress->set_visible(true);

        {
            uint32_t range = _installer->files_count + 3; //+directory creation, uninstaller, registry
            if (_installer->desktop_shortcut) range++;
            if (_installer->menu_shortcut) range++;
            if (_installer->add_to_path) range++;
            _progress->set_range(range);
        }

        _thread = std::thread([](const Window *window, const Installer *installer) -> void
        {
            try
            {
                window->_label_1->set_text(TEXT("Creating directory"));
                window->_progress->step();
                Util::create(installer->directory, true);

                installer->install_files([window](const tstring &message)
                {
                    window->_label_1->set_text(message);
                    window->_progress->step();
                });
                window->_label_1->set_text(TEXT("Installing uninstall.exe"));
                window->_progress->step();
                installer->install_self();
                window->_progress->step();
                window->_label_1->set_text(TEXT("Updating registry"));
                installer->install_registry();
                if (installer->desktop_shortcut)
                {
                    window->_label_1->set_text(TEXT("Creating desktop shortcut"));
                    window->_progress->step();
                    installer->install_desktop_shortcut();
                }
                if (installer->menu_shortcut)
                {
                    window->_label_1->set_text(TEXT("Creating menu icon"));
                    window->_progress->step();
                    installer->install_menu_icon();
                }
                if (installer->add_to_path)
                {
                    window->_label_1->set_text(TEXT("Updating PATH"));
                    window->_progress->step();
                    installer->install_path();
                }
                window->_label_1->set_text(TEXT("Finished"));
                window->_button_next->set_active(true);
            }
            catch (const std::exception& e)
            {
                Util::dialog_error(e.what());
                exit(1); //TODO: proper way to do it?
            }
        }, this, this->_installer);
        
        break;
    case State::finish:
        _label_title->set_text(TEXT("Completing " DEV_NAME_VERSION " Setup"));
        _label_subtitle->set_text(TEXT(DEV_NAME_VERSION " has been installed on your computer."));
        _button_previous->set_active(true);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Finish"));
        _button_cancel->set_active(false);

        _checkbox_1->set_position(30, 120, width - 60, 30);
        _checkbox_1->set_text(TEXT("Run Application"));
        _checkbox_1->set_visible(true);
        _checkbox_1->set_check(_run_application);
        break;
    case State::uninstall_welcome:
        _label_title->set_text(TEXT("Uninstall " DEV_NAME_VERSION));
        _label_subtitle->set_text(TEXT("Remove " DEV_NAME_VERSION " from your computer."));
        _button_previous->set_active(false);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Uninstall"));
        _button_cancel->set_active(true);

        _label_1->set_position(30, 120, width - 60, height - 210);
        _label_1->set_text(TEXT(DEV_NAME_VERSION " will be uninstalled. Click Uninstall to start the uninstallation."));
        _label_1->set_visible(true);
        break;
    case State::uninstall_uninstall:
        _label_title->set_text(TEXT("Uninstalling"));
        _label_subtitle->set_text(TEXT("Please wait while " DEV_NAME_VERSION " is being uninstalled."));
        _button_previous->set_active(false);
        _button_next->set_active(false);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(false);

        _label_1->set_position(30, 120, width - 60, 30);
        _label_1->set_text(TEXT("Initializing"));
        _label_1->set_visible(true);
        _progress->set_visible(true);

        {
            uint32_t range = _installer->files_count + 2; //+registry, self-removal
            if (_installer->desktop_shortcut) range++;
            if (_installer->menu_shortcut) range++;
            if (_installer->add_to_path) range++;
            _progress->set_range(range);
        }

        _thread = std::thread([](const Window *window, Installer *installer) -> void
        {
            try
            {
                installer->uninstall_files([window](const tstring &message)
                {
                    window->_label_1->set_text(message);
                    window->_progress->step();
                });

                window->_label_1->set_text(TEXT("Updating registry"));
                window->_progress->step();
                installer->uninstall_registry();

                if (installer->desktop_shortcut)
                {
                    window->_label_1->set_text(TEXT("Removing desktop shortcut"));
                    window->_progress->step();
                    installer->uninstall_desktop_shortcut();
                }

                if (installer->menu_shortcut)
                {
                    window->_label_1->set_text(TEXT("Removing menu icon"));
                    window->_progress->step();
                    installer->uninstall_menu_icon();
                }

                if (installer->add_to_path)
                {
                    window->_label_1->set_text(TEXT("Updating PATH"));
                    window->_progress->step();
                    installer->uninstall_path();
                }

                window->_progress->step();
                CloseHandle(installer->handle);
                installer->handle = INVALID_HANDLE_VALUE;
                Installer::uninstall_self();
            }
            catch (const std::exception& e)
            {
                Util::dialog_error(e.what());
                exit(1); //TODO: proper way to do it?
            }
        }, this, this->_installer);

        break;
    case State::uninstall_finish:
        _label_title->set_text(TEXT("Completing " DEV_NAME_VERSION " uninstallation"));
        _label_subtitle->set_text(TEXT(DEV_NAME_VERSION " has been removed from your computer."));
        _button_previous->set_active(true);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Finish"));
        _button_cancel->set_active(false);
        break;
    }
}

void Window::_button_browse_handler()
{
    tstring dialog_directory = _installer->directory;
    while (true)
    {
        DWORD directory_flags = GetFileAttributes(dialog_directory.c_str());
        bool directory_exists = (directory_flags != INVALID_FILE_ATTRIBUTES && (directory_flags & FILE_ATTRIBUTE_DIRECTORY) != 0);
        if (directory_exists) break;
        Util::pop_slash(&dialog_directory);
    }

    if (Util::dialog_directory(&dialog_directory, TEXT("Please select installation path")))
    {
        _installer->directory = dialog_directory;
        _edit_directory->set_text(dialog_directory);
    }
}

void Window::_button_previous_handler()
{
    if (_state != State::welcome && _state != State::uninstall_welcome)
    {
        _state = static_cast<State>(static_cast<int>(_state) - 1);
        _refresh();
    }
}

void Window::_button_next_handler()
{
    if (_thread.joinable()) _thread.join();

    if (_state != State::finish && _state != State::uninstall_finish)
    {
        _state = static_cast<State>(static_cast<int>(_state) + 1);
        _refresh();
    }
    else
    {
        if (_run_application) _installer->run_application();
        DestroyWindow(_handle);
    }
}

void Window::_button_cancel_handler()
{
    if (Util::dialog_close()) DestroyWindow(_handle);
}

void Window::_checkbox_1_handler()
{
    bool check = !_checkbox_1->get_check();
    _checkbox_1->set_check(check);
    if (_state == State::components) _installer->desktop_shortcut = check;
    else if (_state == State::finish) _run_application = check;
}

void Window::_checkbox_2_handler()
{
    bool check = !_checkbox_2->get_check();
    _checkbox_2->set_check(check);
    if (_state == State::components) _installer->menu_shortcut = check;
}

void Window::_checkbox_3_handler()
{
    bool check = !_checkbox_3->get_check();
    _checkbox_3->set_check(check);
    if (_state == State::components) _installer->add_to_path = check;
}

void Window::_checkbox_4_handler()
{
    bool check = !_checkbox_4->get_check();
    _checkbox_4->set_check(check);
    if (_state == State::components) _installer->install_for_all = check;
}

void Window::_close_handler()
{
    if (!_thread.joinable() && Util::dialog_close()) DestroyWindow(_handle);
}

Window* Window::static_window = nullptr;

bool Window::static_block_commands = false;

Window::Window(HINSTANCE hinstance, Installer *installer) : _state(installer->is_uninstaller ? State::uninstall_welcome : State::welcome), _installer(installer)
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
    const DWORD style = static_cast<DWORD>(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX | WS_VISIBLE);
    if (CreateWindowEx(0, name, caption, style, CW_USEDEFAULT, CW_USEDEFAULT, width, height, NULL, NULL, hinstance, this) == NULL)
        throw std::runtime_error("CreateWindowEx() failed");
}

int Window::run()
{
    MSG message = { };
    while (GetMessage(&message, NULL, 0, 0) > 0) //TODO: exceptions don't actually cause it to fail
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
        //Get command line
        const wchar_t* command = GetCommandLineW();
        int argc;
        wchar_t** argv = CommandLineToArgvW(command, &argc);
        if (argv == nullptr) throw std::runtime_error("CommandLineToArgvW() failed");
        Util::MemoryGuard guard(argv);
        std::unique_ptr<Installer> installer = std::unique_ptr<Installer>(new Installer(hinstance));

        if (!installer->is_uninstaller && argc == 1) //Install
        {
            Window window(hinstance, installer.get());
            return window.run();
        }
        else if (installer->is_uninstaller && wcscmp(argv[1], L"--uninstall") == 0) //Uninstall
        {
            Window window(hinstance, installer.get());
            return window.run();
        }
        else if (installer->is_uninstaller && argc == 2 && wcscmp(argv[1], L"--quiet-uninstall") == 0) //Quietly uninstall
        {
            installer->uninstall_files([](const tstring&) {});
            installer->uninstall_registry();
            if (installer->desktop_shortcut) installer->uninstall_desktop_shortcut();
            if (installer->menu_shortcut) installer->uninstall_menu_icon();
            if (installer->add_to_path) installer->uninstall_path();
            installer.reset(nullptr);
            Installer::uninstall_self();
            return 0;
        }
        else if (installer->is_uninstaller && argc == 3 && wcscmp(argv[1], L"--delete") == 0) //Delete uninstaller (uninstall_self helper)
        {
            //Delete original
            std::wstring path = argv[2];
            while (!DeleteFileW(path.c_str())) {}

            //Delete directory
            try { Util::pop_slash(&path); RemoveDirectoryW(path.c_str()); }
            catch (...) {}

            //Open nul
            SECURITY_ATTRIBUTES security_attributes = { 0 };
            security_attributes.nLength = sizeof(security_attributes);
            security_attributes.bInheritHandle = true;
            HANDLE nul = CreateFile(TEXT("nul"), 0, FILE_SHARE_READ, &security_attributes, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

            //Launch dying process and give it all handles
            STARTUPINFO startup_info = { 0 };
            PROCESS_INFORMATION process_info = { 0 };
            startup_info.cb = sizeof(startup_info);
            startup_info.dwFlags |= STARTF_USESTDHANDLES;
            startup_info.hStdOutput = nul;
            startup_info.hStdError = startup_info.hStdOutput;
            CreateProcess(NULL, TEXT("\"timeout\" /T 1"), NULL, NULL, true, 0, NULL, NULL, &startup_info, &process_info);
            CloseHandle(process_info.hProcess);
            CloseHandle(process_info.hThread);
            return 0;
        }
        else throw std::runtime_error("Invalid arguments");
    }
    catch (const std::exception& e)
    {
        Util::dialog_error(e.what());
        return 1;
    }
}

int WINAPI WinMain(_In_ HINSTANCE hinstance, _In_opt_ HINSTANCE, _In_ PSTR, _In_ int)
{
    return _main(hinstance);
}
#pragma endregion