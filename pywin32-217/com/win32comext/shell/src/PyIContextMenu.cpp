// This file implements the IContextMenu Interface and Gateway for Python.
// Generated by makegw.py

#include "shell_pch.h"
#include "PyIContextMenu.h"

// @doc - This file contains autoduck documentation
// ---------------------------------------------------
//
// Interface Implementation

PyIContextMenu::PyIContextMenu(IUnknown *pdisp):
	PyIUnknown(pdisp)
{
	ob_type = &type;
}

PyIContextMenu::~PyIContextMenu()
{
}

/* static */ IContextMenu *PyIContextMenu::GetI(PyObject *self)
{
	return (IContextMenu *)PyIUnknown::GetI(self);
}

// @pymethod |PyIContextMenu|QueryContextMenu|Adds options to a context menu
PyObject *PyIContextMenu::QueryContextMenu(PyObject *self, PyObject *args)
{
	IContextMenu *pICM = GetI(self);
	if ( pICM == NULL )
		return NULL;
	HMENU hmenu;
	PyObject *obhmenu;
	UINT indexMenu;
	UINT idCmdFirst;
	UINT idCmdLast;
	UINT uFlags;
	if ( !PyArg_ParseTuple(args, "OIIII:QueryContextMenu",
		&obhmenu,		// @pyparm <o PyHANDLE>|hmenu||Handle to menu to which items should be added
		&indexMenu,		// @pyparm int|indexMenu||Zero-based index at which to add first item
		&idCmdFirst,	// @pyparm int|idCmdFirst||Minimum menu item Id
		&idCmdLast,		// @pyparm int|idCmdLast||Max menu item Id
		&uFlags))		// @pyparm int|uFlags||Combination of shellcon.CMF_* flags, can be 0
		return NULL;
	if (!PyWinObject_AsHANDLE(obhmenu, (HANDLE *)&hmenu))
		return NULL;
	HRESULT hr;
	PY_INTERFACE_PRECALL;
	hr = pICM->QueryContextMenu(hmenu, indexMenu, idCmdFirst, idCmdLast, uFlags );

	PY_INTERFACE_POSTCALL;

	if ( FAILED(hr) )
		return PyCom_BuildPyException(hr, pICM, IID_IContextMenu );
	return PyInt_FromLong(hr);
}

// @pymethod |PyIContextMenu|InvokeCommand|Executes a context menu option
PyObject *PyIContextMenu::InvokeCommand(PyObject *self, PyObject *args)
{
	IContextMenu *pICM = GetI(self);
	if ( pICM == NULL )
		return NULL;
	CMINVOKECOMMANDINFO ci;
	PyObject *oblpici;
	if ( !PyArg_ParseTuple(args, "O:InvokeCommand", &oblpici) )
		return NULL;

	if (!PyObject_AsCMINVOKECOMMANDINFO( oblpici, 
		&ci ))	// @pyparm <o PyCMINVOKECOMMANDINFO>|pici||Tuple of parameters representing a CMINVOKECOMMANDINFO struct
		return NULL;
	HRESULT hr;
	PY_INTERFACE_PRECALL;
	hr = pICM->InvokeCommand( &ci );
	PyObject_FreeCMINVOKECOMMANDINFO(&ci);
	PY_INTERFACE_POSTCALL;

	if ( FAILED(hr) )
		return PyCom_BuildPyException(hr, pICM, IID_IContextMenu );
	Py_INCREF(Py_None);
	return Py_None;

}

// @pymethod |PyIContextMenu|GetCommandString|Retrieves verb or help text for a context menu option
PyObject *PyIContextMenu::GetCommandString(PyObject *self, PyObject *args)
{
	IContextMenu *pICM = GetI(self);
	if ( pICM == NULL )
		return NULL;
	// @pyparm int|idCmd||Id of the command
	// @pyparm int|uType||One of the shellcon.GCS_* constants
	// @pyparm int|cchMax|2048|Size of buffer to create for returned string
	PyObject *obCmd;
	UINT uType;
	UINT cchMax = 2048;
	if ( !PyArg_ParseTuple(args, "OI|I:GetCommandString", &obCmd, &uType, &cchMax) )
		return NULL;

	UINT_PTR idCmd;
	if (!PyWinLong_AsULONG_PTR(obCmd, (ULONG_PTR *)&idCmd))
		return NULL;

	char *buf = (char *)malloc(cchMax);
	if (!buf)
		return PyErr_NoMemory();
	HRESULT hr;
	PY_INTERFACE_PRECALL;
	hr = pICM->GetCommandString( idCmd, uType, NULL, buf, cchMax );
	PY_INTERFACE_POSTCALL;

	if ( FAILED(hr) ) {
		free(buf);
		return PyCom_BuildPyException(hr, pICM, IID_IContextMenu );
	}
	PyObject *ret = PyString_FromString(buf);
	free(buf);
	return ret;

}

// @object PyIContextMenu|Description of the interface
static struct PyMethodDef PyIContextMenu_methods[] =
{
	{ "QueryContextMenu", PyIContextMenu::QueryContextMenu, 1 }, // @pymeth QueryContextMenu|Adds options to a context menu
	{ "InvokeCommand", PyIContextMenu::InvokeCommand, 1 }, // @pymeth InvokeCommand|Executes a context menu option
	{ "GetCommandString", PyIContextMenu::GetCommandString, 1 }, // @pymeth GetCommandString|Retrieves verb or help text for a context menu option
	{ NULL }
};

PyComTypeObject PyIContextMenu::type("PyIContextMenu",
		&PyIUnknown::type,
		sizeof(PyIContextMenu),
		PyIContextMenu_methods,
		GET_PYCOM_CTOR(PyIContextMenu));
// ---------------------------------------------------
//
// Gateway Implementation
STDMETHODIMP PyGContextMenu::QueryContextMenu(
		/* [unique][in] */ HMENU hmenu,
		/* [unique][in] */ UINT indexMenu,
		/* [unique][in] */ UINT idCmdFirst,
		/* [unique][in] */ UINT idCmdLast,
		/* [unique][in] */ UINT uFlags)
{
	PY_GATEWAY_METHOD;
	PyObject *ret;
	HRESULT hr=InvokeViaPolicy("QueryContextMenu", &ret, "NIIII", PyWinLong_FromHANDLE(hmenu), indexMenu, idCmdFirst, idCmdLast, uFlags);
	if (FAILED(hr)) return hr;
	if (PyInt_Check(ret))
		hr = MAKE_HRESULT(SEVERITY_SUCCESS, 0, PyInt_AsLong(ret));
	Py_DECREF(ret);
	return hr;
}

STDMETHODIMP PyGContextMenu::InvokeCommand(
		/* [unique][in] */ CMINVOKECOMMANDINFO __RPC_FAR * lpici)
{
	PY_GATEWAY_METHOD;
	PyObject *oblpici = PyObject_FromCMINVOKECOMMANDINFO(lpici);
	if (oblpici==NULL) return MAKE_PYCOM_GATEWAY_FAILURE_CODE("InvokeCommand");
	HRESULT hr=InvokeViaPolicy("InvokeCommand", NULL, "(O)", oblpici);
	Py_DECREF(oblpici);
	return hr;
}

STDMETHODIMP PyGContextMenu::GetCommandString(
		/* [unique][in] */ UINT_PTR idCmd,
		/* [unique][in] */ UINT uFlags,
		/* [unique][in] */ UINT * pwReserved,
		/* [unique][in] */ LPSTR pszName,
		/* [unique][in] */ UINT cchMax)
{
	PyObject *result;
	PY_GATEWAY_METHOD;
	HRESULT hr=InvokeViaPolicy("GetCommandString", &result, "NI", PyWinObject_FromULONG_PTR(idCmd), uFlags);
	if (FAILED(hr))
		return hr;
	if (result && (PyString_Check(result) || PyUnicode_Check(result))) {
		if (uFlags==GCS_HELPTEXTW || uFlags==GCS_VERBW) {
			WCHAR *szResult;
			if (PyWinObject_AsWCHAR(result, &szResult, FALSE, NULL)) {
				wcsncpy((WCHAR *)pszName, szResult, cchMax);
				PyWinObject_FreeWCHAR(szResult);
			}
		} else {
			char *szResult;
			if (PyWinObject_AsString(result, &szResult, FALSE, NULL)) {
				strncpy(pszName, szResult, cchMax);
				PyWinObject_FreeString(szResult);
			}
		}
		hr = S_OK;
	} else if (result && PyInt_Check(result)) {
		hr = PyInt_AsLong(result) ? S_OK : S_FALSE;
	}
	Py_DECREF(result);
	return hr;
}
