#include <Windows.h>
#include <string>
#include <stdexcept>
#include <iostream>

typedef std::basic_string<TCHAR> tstring;

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
#endif

struct FileGuard { HANDLE r; FileGuard(HANDLE r) : r(r) {} ~FileGuard() { CloseHandle(r); } };
struct FindGuard { HANDLE r; FindGuard(HANDLE r) : r(r) {} ~FindGuard() { FindClose(r); } };

const unsigned char BackHeader::right_signature[8] = { 137, 20, 14, 78, 66, 7, 48, 183 };

tstring get_executable_path()
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

void copy(HANDLE handle, HANDLE whandle, uint64_t size)
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

/*
void remove(unsigned int depth, std::function<void(const tstring&)> callback, const tstring &directory, size_t absolute_size)
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
*/

int _main()
{
    try
    {
        tstring self_path = get_executable_path();
        tstring installer_path = self_path.substr(0, self_path.rfind('\\') + 1);
        tstring installer_path = self_path.substr(0, self_path.rfind('\\') + 1);
        FileGuard installer(CreateFile(installer_path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL));
        if (installer.r == INVALID_HANDLE_VALUE) throw std::runtime_error("CreateFile() failed");

    }
    catch (const std::exception& e)
    {
        std::cerr << e.what() << std::endl;
        return 1;
    }
}

int main()
{
	return _main();
}