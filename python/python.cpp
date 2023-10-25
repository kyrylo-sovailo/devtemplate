#include "../include/devtemplate/devtemplate.h"
#include <pybind11/pybind11.h>

#define STRING2(s) #s
#define STRING(s) STRING2(s)

PYBIND11_MODULE(DEVTEMPLATE_FILE_NAME, m)
{
    m.doc() = STRING(DEVTEMPLATE_DESCRIPTION);

    pybind11::class_<devtemplate::Devtemplate>(m, STRING(DEVTEMPLATE_NAME), "Class example")
        .def(pybind11::init<>(),                                            "Creates example class instance")
        .def("devtemplate",      &devtemplate::Devtemplate::devtemplate,    "Executes devtemplate example");
}