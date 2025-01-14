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

class Util
{
public:
    //Guards
    struct ObjectGuard { IUnknown* r; ObjectGuard(IUnknown* r) : r(r) {} ~ObjectGuard() { r->Release(); } };
    struct FileGuard { HANDLE r; FileGuard(HANDLE r) : r(r) {} ~FileGuard() { CloseHandle(r); } };
    struct RegistryGuard { HKEY r; RegistryGuard(HKEY r) : r(r) {} ~RegistryGuard() { RegCloseKey(r); } };
    struct FindGuard { HANDLE r; FindGuard(HANDLE r) : r(r) {} ~FindGuard() { FindClose(r); } };
    struct MemoryGuard { HLOCAL r; MemoryGuard(HLOCAL r) : r(r) {} ~MemoryGuard() { LocalFree(r); } };

    //Lowest level
    static const unsigned char right_signature[8];
    struct FileHeader
    {
        uint32_t files_count;
        uint32_t payload_begin;
        unsigned char signature[8];
    };
    static HANDLE open_self(uint32_t* file_size, uint32_t *files_count, uint32_t *payload_begin);

    //Low level
    static void create_shortcut(const tstring& target_path, const tstring& shortcut_path, const tstring& description);
    static bool dialog_directory(tstring *directory, const tstring& description);
    static bool dialog_close();
    static tstring get_executable_path();
    static tstring get_executable_directory();
    static tstring get_default_directory(HINSTANCE hinstance);
    static std::wstring string_to_wstring(const std::string& string);
    static std::string wstring_to_string(const std::wstring& string);
    static uint64_t get_available_space();
    static uint64_t get_required_space();
    static tstring get_space_string(uint64_t space);
    static tstring get_license();

    //Install
    static void install_files(const tstring& directory, std::function<void(unsigned int, unsigned int)> callback);
    static void install_self(const tstring& directory);
    static void install_registry(const tstring& directory, bool for_all);
    static void install_desktop_shortcut(const tstring& directory, bool for_all);
    static void install_menu_icon(const tstring& directory, bool for_all);
    static void install_path(const tstring& directory, bool for_all);
    static void run_application(const tstring& directory);

    //Uninstall
    static void uninstall_files(std::function<void(unsigned int, unsigned int)> callback);
    static void uninstall_self();
    static void uninstall_registry();
    static void uninstall_desktop_shortcut();
    static void uninstall_menu_icon();
    static void uninstall_path();
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
    tstring _directory;
    bool _desktop_shortcut = true;
    bool _menu_shortcut = true;
    bool _add_to_path = true;
    bool _install_for_all = true;
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
    Window(HINSTANCE hinstance, bool uninstall);
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
    if (!SendMessage(_handle, WM_SETTEXT, 0, reinterpret_cast<LPARAM>(text.c_str())))
        throw std::runtime_error("SendMessage(WM_SETTEXT) failed");
}

std::wstring Control::get_text()
{
    std::wstring text(512, '\0');
    while (true)
    {
        const int len = GetWindowText(_handle, &text[0], static_cast<int>(text.size()));
        if (len < 0) throw std::runtime_error("GetWindowText() failed");
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

Progress::Progress(const Parent *parent, unsigned int range, int left, int top, int width, int height)
{
    const DWORD style = static_cast<DWORD>(WS_VISIBLE | WS_CHILD | BS_CENTER | BS_TEXT | BS_VCENTER);
    _handle = CreateWindowEx(0, PROGRESS_CLASS, TEXT("progress"), style, left, top, width, height, parent->handle(), NULL, NULL, NULL);
    if (_handle == NULL) throw std::runtime_error("CreateWindowEx() failed");
    SendMessage(_handle, PBM_SETRANGE, 0, MAKELPARAM(0, range));
    SendMessage(_handle, PBM_SETSTEP, (WPARAM)1, 0);
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

const unsigned char Util::right_signature[8] = { 137, 20, 14, 78, 66, 7, 48, 183 };

HANDLE Util::open_self(uint32_t* file_size, uint32_t* files_count, uint32_t* payload_begin)
{
    tstring executable_path = get_executable_path();
    HANDLE handle = CreateFile(executable_path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (handle == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
    DWORD _file_size = GetFileSize(handle, nullptr);
    DWORD bytes;
    FileHeader header;
    SetFilePointer(handle, static_cast<LONG>(_file_size - sizeof(header)), nullptr, FILE_BEGIN);
    if (!ReadFile(handle, &header, sizeof(header), &bytes, nullptr) || bytes != sizeof(header))
        { CloseHandle(handle); throw std::runtime_error("ReadFile() failed"); }
    if (memcmp(header.signature, right_signature, sizeof(right_signature)) != 0)
        { CloseHandle(handle); throw std::runtime_error("Invalid signature"); }
    if (file_size != nullptr) *file_size = _file_size;
    if (files_count != nullptr) *files_count = header.files_count;
    if (payload_begin != nullptr) *payload_begin = header.payload_begin;
    SetFilePointer(handle, static_cast<LONG>(header.payload_begin), nullptr, FILE_BEGIN);
    return handle;
}

void Util::create_shortcut(const tstring& target_path, const tstring& link_path, const tstring& description)
{
    IShellLink* shell;
    if (!SUCCEEDED(CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&shell))))
        throw std::runtime_error("CoCreateInstance() failed");
    ObjectGuard guard1(shell);

    if (!SUCCEEDED(shell->SetPath(target_path.c_str())))
        throw std::runtime_error("IShellLink::SetPath() failed");

    if (!SUCCEEDED(shell->SetDescription(description.c_str())))
        throw std::runtime_error("IShellLink::SetDescription() failed");

    IPersistFile* file;
    if (!SUCCEEDED(shell->QueryInterface(IID_PPV_ARGS(&file))))
        throw std::runtime_error("IShellLink::QueryInterface() failed");
    ObjectGuard guard2(file);

    if (!SUCCEEDED(file->Save(link_path.c_str(), TRUE)))
        throw std::runtime_error("IPersistFile::Save() failed");
}

bool Util::dialog_directory(tstring* directory, const tstring& description)
{
    IShellItem* shell = NULL;
    if (!SUCCEEDED(SHCreateItemFromParsingName(directory->c_str(), NULL, IID_PPV_ARGS(&shell))))
        throw std::runtime_error("SHCreateItemFromParsingName() failed");
    ObjectGuard guard1(shell);

    IFileDialog* dialog;
    if (!SUCCEEDED(CoCreateInstance(CLSID_FileOpenDialog, NULL, CLSCTX_INPROC_SERVER, IID_PPV_ARGS(&dialog))))
        throw std::runtime_error("CoCreateInstance() failed");
    ObjectGuard guard2(dialog);

    DWORD flags;
    if (!SUCCEEDED(dialog->GetOptions(&flags)))
        throw std::runtime_error("IFileDialog::GetOptions() failed");

    if (!SUCCEEDED(dialog->SetOptions(flags | FOS_PICKFOLDERS)))
        throw std::runtime_error("IFileDialog::SetOptions() failed");

    if (!SUCCEEDED(dialog->SetTitle(description.c_str())))
        throw std::runtime_error("IFileDialog::SetTitle() failed");

    if (!SUCCEEDED(dialog->SetDefaultFolder(shell)) || !SUCCEEDED(dialog->SetFolder(shell)))
        throw std::runtime_error("IFileDialog::SetDefaultFolder() failed");

    if (!SUCCEEDED(dialog->Show(NULL))) return false;

    IShellItem* result;
    if (!SUCCEEDED(dialog->GetResult(&result))) return false;
    ObjectGuard guard3(result);

    PWSTR selected;
    if (!SUCCEEDED(result->GetDisplayName(SIGDN_FILESYSPATH, &selected))) return false;
    *directory = selected;
    CoTaskMemFree(selected);
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
    directory.resize(directory.rfind('\\') + 1);
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

uint64_t Util::get_required_space()
{
    uint32_t file_size, payload_begin;
    HANDLE handle = open_self(&file_size, nullptr, &payload_begin);
    FileGuard guard(handle);
    return static_cast<uint64_t>(file_size) - static_cast<uint64_t>(payload_begin);
}

tstring Util::get_space_string(uint64_t space)
{
    uint64_t unit;
    const TCHAR* unit_name;
    if (space < 1000) { unit = 1; unit_name = TEXT("B"); }
    else if (space < 1000'000) { unit = 1000; unit_name = TEXT("KB"); }
    else if (space < 1000'000'000) { unit = 1000'000; unit_name = TEXT("MB"); }
    else if (space < 1000'000'000'000) { unit = 1000'000'000; unit_name = TEXT("GB"); }
    else { unit = 1000'000'000'000; unit_name = TEXT("TB"); }
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

void Util::install_files(const tstring& diretory, std::function<void(unsigned int, unsigned int)> callback)
{
    uint32_t files_count;
    HANDLE handle = open_self(nullptr, &files_count, nullptr);
    FileGuard guard(handle);
    
    //Process
    for (uint32_t i = 0; i < files_count; i++)
    {
        //Read path
        DWORD bytes;
        uint32_t relative_path_size;
        if (!ReadFile(handle, &relative_path_size, sizeof(relative_path_size), &bytes, nullptr) || bytes != sizeof(relative_path_size))
            throw std::runtime_error("ReadFile() failed");
        std::wstring relative_path(relative_path_size, '\0');
        if (!ReadFile(handle, &relative_path_size, relative_path_size * sizeof(wchar_t), &bytes, nullptr) || bytes != relative_path_size * sizeof(wchar_t))
            throw std::runtime_error("ReadFile() failed");

        //Read size
        uint32_t wfile_size;
        if (!ReadFile(handle, &wfile_size, sizeof(wfile_size), &bytes, nullptr) || bytes != sizeof(wfile_size))
            throw std::runtime_error("ReadFile() failed");

        //Write file
        std::wstring absolute_path = diretory + relative_path;
        HANDLE whandle = CreateFile(absolute_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL);
        if (whandle == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
        FileGuard guard2(whandle);
        while (wfile_size > 0)
        {
            char buffer[4096];
            DWORD to_read = (wfile_size > sizeof(buffer)) ? sizeof(buffer) : wfile_size;
            if (!ReadFile(handle, buffer, to_read, &bytes, nullptr) || bytes != to_read) throw std::runtime_error("ReadFile() failed");
            if (!WriteFile(whandle, buffer, to_read, &bytes, nullptr) || bytes != to_read) throw std::runtime_error("WriteFile() failed");
            wfile_size -= to_read;
        }
    }
}

void Util::install_self(const tstring& directory)
{
    uint32_t files_count, payload_begin;
    HANDLE handle = open_self(nullptr, &files_count, &payload_begin);
    FileGuard guard(handle);
    SetFilePointer(handle, 0, nullptr, FILE_BEGIN);

    //Write file
    DWORD bytes;
    tstring absolute_path = directory + TEXT("uninstall.exe");
    HANDLE whandle = CreateFile(absolute_path.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL);
    if (whandle == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");
    FileGuard guard2(whandle);
    for (DWORD wfile_size = payload_begin; wfile_size > 0;)
    {
        char buffer[4096];
        DWORD to_read = (wfile_size > sizeof(buffer)) ? sizeof(buffer) : wfile_size;
        if (!ReadFile(handle, buffer, to_read, &bytes, nullptr) || bytes != to_read) throw std::runtime_error("ReadFile() failed");
        if (!WriteFile(whandle, buffer, to_read, &bytes, nullptr) || bytes != to_read) throw std::runtime_error("WriteFile() failed");
        wfile_size -= to_read;
    }

    //Write header
    FileHeader header;
    header.files_count = files_count;
    header.payload_begin = payload_begin;
    memcpy(header.signature, right_signature, sizeof(right_signature));
    if (!WriteFile(whandle, &header, sizeof(header), &bytes, nullptr) || bytes != sizeof(header)) throw std::runtime_error("WriteFile() failed");
}

void Util::install_registry(const tstring& directory, bool for_all)
{
    HKEY key = for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
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
    d = static_cast<DWORD>(get_required_space() / static_cast<uint64_t>(1000)); //Assuming kilobytes
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

void Util::install_desktop_shortcut(const tstring& directory, bool for_all)
{
    TCHAR desktop_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, for_all ? CSIDL_COMMON_DESKTOPDIRECTORY : CSIDL_DESKTOPDIRECTORY, NULL, 0, desktop_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring desktop_directory = desktop_directory_array;
    create_shortcut(directory + TEXT(DEV_NAME ".exe"), desktop_directory + TEXT(DEV_NAME ".lnk"), TEXT("TODO: Write description"));
}

void Util::install_menu_icon(const tstring& directory, bool for_all)
{
    //TODO: refactor
    TCHAR desktop_directory_array[MAX_PATH];
    if (SHGetFolderPath(NULL, for_all ? CSIDL_COMMON_PROGRAMS : CSIDL_PROGRAMS, NULL, 0, desktop_directory_array) != S_OK)
        throw std::runtime_error("SHGetFolderPath() failed");
    tstring desktop_directory = desktop_directory_array;
    create_shortcut(directory + TEXT(DEV_NAME ".exe"), desktop_directory + TEXT(DEV_NAME ".lnk"), TEXT("TODO: Write description"));
}

void Util::install_path(const tstring& location, bool for_all)
{
    //Get path
    HKEY key = for_all ? HKEY_LOCAL_MACHINE : HKEY_CURRENT_USER;
    const TCHAR* subkey = for_all ? TEXT("SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Environment\\") : TEXT("Environment\\");
    tstring path;
    DWORD path_size = 0;
    if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, NULL, &path_size) == ERROR_SUCCESS)
    {
        path.resize(path_size / sizeof(TCHAR), '\0');
        if (RegGetValue(key, subkey, TEXT("PATH"), RRF_RT_REG_SZ, NULL, &path[0], &path_size) != ERROR_SUCCESS)
            throw std::runtime_error("RegGetValue() failed");
    }

    //Process path
    if (path.empty() || path.back() != ';') path += ';';
    path += location;

    //Set path
    if (RegSetKeyValue(key, subkey, TEXT("PATH"), REG_SZ, path.c_str(), static_cast<DWORD>(path.size() * sizeof(TCHAR))) != ERROR_SUCCESS)
        throw std::runtime_error("RegSetKeyValue() failed");
}

void Util::run_application(const tstring& directory)
{
    STARTUPINFO startup_info = { 0 };
    startup_info.cb = sizeof(startup_info);
    PROCESS_INFORMATION process_info = { 0 };
    tstring path = directory + TEXT(DEV_NAME ".exe");
    CreateProcess(path.c_str(), nullptr, nullptr, nullptr, false, 0, nullptr, nullptr, &startup_info, &process_info);
    CloseHandle(process_info.hProcess);
    CloseHandle(process_info.hThread);
}

void Util::uninstall_files(std::function<void(unsigned int, unsigned int)> callback)
{
    struct Remove
    {
        static void remove(unsigned int depth, unsigned int * progress, unsigned int total, std::function<void(unsigned int, unsigned int)> callback, const tstring &directory)
        {
            tstring pattern = directory + TEXT("*");
            WIN32_FIND_DATA find;
            HANDLE handle = FindFirstFile(pattern.c_str(), &find);
            if (handle == INVALID_HANDLE_VALUE) return;
            FindGuard guard(handle);

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
                    remove(depth + 1, progress, total, callback, path);
                    if (!RemoveDirectory(path.c_str())) throw std::runtime_error("RemoveDirectory() failed");
                }
                else
                {
                    tstring path = directory + TEXT("\\") + find.cFileName;
                    if (!DeleteFile(path.c_str())) throw std::runtime_error("DeleteFile() failed");
                    (*progress)++;
                    callback(*progress, total);
                }
                if (!FindNextFile(handle, &find)) break;
            }
        }
    };

    uint32_t files_count;
    HANDLE handle = open_self(nullptr, &files_count, nullptr);
    CloseHandle(handle);

    unsigned int progress = 0;
    Remove::remove(0, &progress, files_count, callback, get_executable_directory());
}

void Util::uninstall_self()
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
    tstring self = get_executable_path();
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

void Util::uninstall_registry()
{}

void Util::uninstall_desktop_shortcut()
{}

void Util::uninstall_menu_icon()
{}

void Util::uninstall_path()
{}
#pragma endregion

#pragma region Window implementation
LRESULT CALLBACK Window::_handler(HWND handle, UINT message, WPARAM wparam, LPARAM lparam)
{
    static Window* window = nullptr;

    try
    {
        switch (message)
        {
        case WM_CREATE:
        {
            window = static_cast<Window*>((reinterpret_cast<CREATESTRUCT*>(lparam))->lpCreateParams);
            window->_initialize(handle);
            return 0;
        }
        case WM_COMMAND:
        {
            if (HIWORD(wparam) == BN_CLICKED && window->_button_browse->identify(wparam)) window->_button_browse_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_button_previous->identify(wparam)) window->_button_previous_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_button_next->identify(wparam)) window->_button_next_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_button_cancel->identify(wparam)) window->_button_cancel_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_checkbox_1->identify(wparam)) window->_checkbox_1_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_checkbox_2->identify(wparam)) window->_checkbox_2_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_checkbox_3->identify(wparam)) window->_checkbox_3_handler();
            else if (HIWORD(wparam) == BN_CLICKED && window->_checkbox_4->identify(wparam)) window->_checkbox_4_handler();
            else break;
            return 0;
        }
        case WM_CLOSE:
        {
            window->_close_handler();
            if (Util::dialog_close()) DestroyWindow(handle);
            return 0;
        }
        case WM_ERASEBKGND:
        {
            HDC hdc = (HDC)(wparam);
            RECT rect;
            GetClientRect(handle, &rect);
            FillRect(hdc, &rect, window->_background_brush);
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
        const TCHAR* text;
        #if UNICODE
            std::wstring wtext = Util::string_to_wstring(e.what());
            text = wtext.c_str();
        #else
            text = e.what();
        #endif
        MessageBox(NULL,
            TEXT("Are you sure you want to quit " DEV_NAME_VERSION " Setup"),
            TEXT("Error"),
            MB_ICONERROR | MB_OK);
        std::cerr << e.what() << std::endl;
        return -1;
    }
}

void Window::_initialize(HWND handle)
{
    _handle = handle;
    _background_brush = CreateSolidBrush(RGB(240, 240, 240));
    _directory = Util::get_default_directory(_window_class.hInstance);
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
    _edit_directory = std::unique_ptr<Edit>(new Edit(this, _common_font.get(), TEXT("C:\\Program Files\\"), 45, 215 + 4, width - 190, 30));
    _button_browse = std::unique_ptr<Button>(new Button(this, _common_font.get(), TEXT("Browse"), false, width - 135, 215 + 4, 90, 30));
    _progress = std::unique_ptr<Progress>(new Progress(this, 100, 30, 150, width - 60, 30));
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
        _label_2->set_text(TEXT("Space required: 10.0 Mb\r\n"
            "Space available : 10.0 Gb"));
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
        _checkbox_1->set_check(_desktop_shortcut);
        _checkbox_2->set_position(30, 180, width - 60, 30);
        _checkbox_2->set_text(TEXT("Create Entry in Start Menu"));
        _checkbox_2->set_visible(true);
        _checkbox_2->set_check(_menu_shortcut);
        _checkbox_3->set_position(30, 240, width - 60, 30);
        _checkbox_3->set_text(TEXT("Add install directory to PATH"));
        _checkbox_3->set_visible(true);
        _checkbox_3->set_check(_add_to_path);
        _checkbox_3->set_position(30, 300, width - 60, 30);
        _checkbox_3->set_text(TEXT("Install for all Users on the Machine"));
        _checkbox_3->set_visible(true);
        _checkbox_3->set_check(_install_for_all);
        break;
    case State::install:
        _label_title->set_text(TEXT("Installing"));
        _label_subtitle->set_text(TEXT("Please wait while " DEV_NAME_VERSION " is being installed."));
        _button_previous->set_active(false);
        _button_next->set_active(true);
        _button_next->set_text(TEXT("Next >"));
        _button_cancel->set_active(false);

        _label_1->set_position(30, 120, width - 60, 30);
        _label_1->set_text(TEXT("Extract: filename.dll"));
        _label_1->set_visible(true);
        _progress->set_visible(true);
        break;
    case State::finish:
        _label_title->set_text(TEXT("Completing " DEV_NAME_VERSION " Setup"));
        _label_subtitle->set_text(TEXT("" DEV_NAME_VERSION " has been installed on your computer."));
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
        break;
    case State::uninstall_uninstall:
        break;
    case State::uninstall_finish:
        break;
    }
}

void Window::_button_browse_handler()
{
    tstring directory = Util::get_default_directory(_window_class.hInstance);
    if (Util::dialog_directory(&directory, TEXT("Please select installation path")))
    {
        _edit_directory->set_text(directory);
    }
}

void Window::_button_previous_handler()
{
    if (_state != State::welcome)
    {
        _state = static_cast<State>(static_cast<int>(_state) - 1);
        _refresh();
    }
}

void Window::_button_next_handler()
{
    if (_state != State::finish)
    {
        _state = static_cast<State>(static_cast<int>(_state) + 1);
        _refresh();
    }
    else
    {
        DestroyWindow(_handle);
    }
}

void Window::_button_cancel_handler()
{
    if (Util::dialog_close()) DestroyWindow(_handle);
}

void Window::_checkbox_1_handler()
{
    _checkbox_1->set_check(!_checkbox_1->get_check());
}

void Window::_checkbox_2_handler()
{
    _checkbox_2->set_check(!_checkbox_2->get_check());
}

void Window::_checkbox_3_handler()
{
    _checkbox_3->set_check(!_checkbox_3->get_check());
}

void Window::_checkbox_4_handler()
{
    _checkbox_4->set_check(!_checkbox_4->get_check());
}

void Window::_close_handler()
{
    if (Util::dialog_close()) DestroyWindow(_handle);
}

Window::Window(HINSTANCE hinstance, bool uninstall) : _state(uninstall ? State::uninstall_welcome : State::welcome)
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
        //Get command line
        const wchar_t* command = GetCommandLineW();
        int argc;
        wchar_t** argv = CommandLineToArgvW(command, &argc);
        if (argv == nullptr) throw std::runtime_error("CommandLineToArgvW() failed");
        Util::MemoryGuard guard(argv);

        if (argc == 2 && wcscmp(argv[1], L"--uninstall") == 0) //Uninstall
        {
            Window window(hinstance, true);
            return window.run();
        }
        else if (argc == 2 && wcscmp(argv[1], L"--quiet-uninstall") == 0) //Quiet uninstall
        {
            Util::uninstall_files([](unsigned int, unsigned int) {});
            Util::uninstall_registry();
            Util::uninstall_desktop_shortcut();
            Util::uninstall_menu_icon();
            Util::uninstall_path();

            Util::uninstall_self();
            return 0;
        }
        else if (argc == 3 && wcscmp(argv[1], L"--delete") == 0) //Delete
        {
            //Delete original
            std::wstring path = argv[2];
            while (!DeleteFileW(path.c_str())) {}
            size_t last = path.rfind('\\');
            if (last != std::wstring::npos)
            {
                path.resize(last + 1);
                RemoveDirectoryW(path.c_str());
            }

            //Open nul
            SECURITY_ATTRIBUTES security_attributes = { 0 };
            security_attributes.nLength = sizeof(security_attributes);
            security_attributes.bInheritHandle = true;
            HANDLE nul = CreateFile(TEXT("nul"), 0, FILE_SHARE_READ, &security_attributes, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);

            //Launch other process and give it all handles
            STARTUPINFO startup_info = { 0 };
            PROCESS_INFORMATION process_info = { 0 };
            startup_info.cb = sizeof(startup_info);
            startup_info.dwFlags |= STARTF_USESTDHANDLES;
            startup_info.hStdOutput = nul;
            startup_info.hStdError = startup_info.hStdOutput;
            CreateProcess(NULL, TEXT("timeout /T 1"), NULL, NULL, true, 0, NULL, NULL, &startup_info, &process_info);
            CloseHandle(process_info.hProcess);
            CloseHandle(process_info.hThread);
            return 0;
        }
        else //Install
        {
            Window window(hinstance, false);
            return window.run();
        }
    }
    catch (const std::exception& e)
    {
        const TCHAR* text;
        #if UNICODE
            std::wstring wtext = Util::string_to_wstring(e.what());
            text = wtext.c_str();
        #else
            text = e.what();
        #endif
        MessageBox(NULL,
            TEXT("Are you sure you want to quit " DEV_NAME_VERSION " Setup"),
            TEXT("Error"),
            MB_ICONERROR | MB_OK);
        std::cerr << e.what() << std::endl;
        return 1;
    }
}

int WINAPI WinMain(_In_ HINSTANCE hinstance, _In_opt_ HINSTANCE, _In_ PSTR, _In_ int)
{
    return _main(hinstance);
}
#pragma endregion