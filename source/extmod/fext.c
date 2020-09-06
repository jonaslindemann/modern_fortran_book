#include "Python.h"

// The calculation function

static PyObject* sum(PyObject *self, PyObject *args)
{
    double a;
    double b;
    double c;
    
    // Parse input arguments
    
    if (!PyArg_ParseTuple(args, "dd", &a, &b)) 
        return NULL;
    
    // Do our computation
    
    forsum(a, b, &c);
    
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
initfext(void)
{
    Py_InitModule3("fext", module_functions, "A minimal module.");
}
