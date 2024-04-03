#include <devtemplate/devtemplate.h>

#include <pybind11/pybind11.h>

PYBIND11_MODULE(DEVTEMPLATE_FILE_NAME, m)
{
    m.doc() = DEV_STRING(DEVTEMPLATE_DESCRIPTION);

    pybind11::class_<devtemplate::Devtemplate>(m, DEV_STRING(DEVTEMPLATE_NAME), "Class example")
        .def(pybind11::init<>(),                                            "Creates example class instance")
        .def_static("version",  &devtemplate::Devtemplate::version,         "Returns information about Devtemplate version")
        .def_static("major",    &devtemplate::Devtemplate::major,           "Returns major version")
        .def_static("minor",    &devtemplate::Devtemplate::minor,           "Returns minor version")
        .def_static("patch",    &devtemplate::Devtemplate::patch,           "Returns patch version")
        .def_static("size",     &devtemplate::Devtemplate::size,            "Returns pointer size")
        .def_static("debug",    &devtemplate::Devtemplate::debug,           "Returns if debug version")
        .def("calculate",       &devtemplate::Devtemplate::calculate,       "Returns result of Devtemplate calculations")
        #ifdef DEVTEMPLATE_ADVANCED
            .def("calculate_advanced", &devtemplate::Devtemplate::calculate_advanced, "Returns result of advanced Devtemplate calculations")
        #endif
        ;
}