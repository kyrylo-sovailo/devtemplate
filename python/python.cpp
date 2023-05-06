#include "../include/devtemplate/devtemplate.h"
#include <pybind11/pybind11.h>

PYBIND11_MODULE(devtemplate, m)
{
    m.doc() = "devtemplate is a template repository for C++/Python/CMake/Doxygen/VS Code stack.";

    pybind11::class_<devtemplate::Devtemplate>(m, "Devtemplate", "Class example")
        .def(pybind11::init<>(),                                            "Creates example class instance")
        .def("devtemplate",         &devtemplate::Devtemplate::devtemplate, "Executes devtemplate example");
}