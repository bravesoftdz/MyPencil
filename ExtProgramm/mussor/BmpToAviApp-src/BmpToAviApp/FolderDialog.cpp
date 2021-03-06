// Copyleft 2005 Chris Korda
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation; either version 2 of the License, or any later version.
/*
        chris korda
 
		revision history:
		rev		date	comments
        00      28jan02 initial version
		01		09jan03	fixed cancel case
		02		23nov07	support Unicode
		03		28oct08	add initial directory

        Browses for a folder.
 
*/

#include "stdafx.h"
#include "FolderDialog.h"
#include <afxpriv.h>	// for MBCS/Unicode conversion macros

int CALLBACK CFolderDialog::BrowseCallbackProc(HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData)
{
	switch (uMsg) {
	case BFFM_INITIALIZED:
		if (lpData != NULL)
			SendMessage(hWnd, BFFM_SETSELECTION, TRUE, (LPARAM)lpData);
		break;
	}
	return 0;
}

bool CFolderDialog::GetItemIdListFromPath(LPCTSTR lpszPath, LPITEMIDLIST *lpItemIdList)
{
#ifdef UNICODE
	LPWSTR	path = const_cast<LPWSTR>(lpszPath);
#else
	USES_CONVERSION;
	LPWSTR	path = A2W(lpszPath);
#endif
	LPSHELLFOLDER pShellFolder = NULL;
	HRESULT	hr;
	ULONG	chUsed;
	// Get desktop IShellFolder interface
	if (SHGetDesktopFolder(&pShellFolder) != NOERROR)
		return(FALSE);     // failed
	// convert the path to an ITEMIDLIST
	hr = pShellFolder->ParseDisplayName(NULL, NULL, path, &chUsed, lpItemIdList, NULL);
	if (FAILED(hr)) {
		pShellFolder->Release();
		*lpItemIdList = NULL;
		return(FALSE);
	}
	pShellFolder->Release();
	return(TRUE);
}

bool CFolderDialog::BrowseFolder(LPCTSTR Title, CString& Folder, LPCTSTR Root, UINT Flags, LPCTSTR InitialDir)
{
	LPMALLOC lpMalloc;
	if (::SHGetMalloc(&lpMalloc) != NOERROR)
		return(FALSE);
	bool retc = FALSE;
	TCHAR	szDisplayName[_MAX_PATH];
	TCHAR	szBuffer[_MAX_PATH];
	LPITEMIDLIST pidlRoot = 0;
	if (Root)
		GetItemIdListFromPath(Root, &pidlRoot);
    BROWSEINFO	bi;
	ZeroMemory(&bi, sizeof(bi));
	bi.hwndOwner = AfxGetMainWnd()->m_hWnd;
    bi.pidlRoot = pidlRoot;
    bi.pszDisplayName = szDisplayName;
    bi.lpszTitle = Title;
    bi.ulFlags = Flags;
	if (InitialDir) {
	    bi.lpfn = BrowseCallbackProc;
		bi.lParam = (LPARAM)InitialDir;
	}
	LPITEMIDLIST lpItemIDList = SHBrowseForFolder(&bi);
	if (lpItemIDList) {
		if (SHGetPathFromIDList(lpItemIDList, szBuffer)) {
			Folder = szBuffer;
			retc = TRUE;
		}
	}
	lpMalloc->Free(lpItemIDList);
	lpMalloc->Release();  
	if (pidlRoot)
		lpMalloc->Free(pidlRoot);
    return(retc);
}
