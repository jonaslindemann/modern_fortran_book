#include "Python.h"

// The calculation function

static PyObject* sum(PyObject *self, PyObject *args)
{
    double a;
    double b;
    
    // Parse input arguments
    
    if (!PyArg_ParseTuple(args, "dd", &a, &b)) 
        return NULL;
    
    // Do our computation
    
    double c = a + b;
    
    // Return the results

    return Py_BuildValue("d", c);
}

// Module function table.

static PyMethodDef
module_functions[] = {
    { "sum", sum, METH_VARARGS, "Calculate sum." },
    { NULL }
};

// Module initialisation

void
initcext(void)
{
    Py_InitModule3("cext", module_functions, "A minimal module.");
}
