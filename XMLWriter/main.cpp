#define _RSDLL

#include "DLL_Header.h"

/**
 * 테스트 XML 파일을 작성합니다.
 */
RSDLL DWORD RSCreateDoc(char* path)
{
	TiXmlDocument doc;
	TiXmlElement* msg;
	TiXmlDeclaration* decl = new TiXmlDeclaration("1.0", "", "");
	doc.LinkEndChild(decl);

	TiXmlElement * root = new TiXmlElement("MyApp");
	doc.LinkEndChild(root);

	TiXmlComment * comment = new TiXmlComment();
	comment->SetValue(" Settings for MyApp ");
	root->LinkEndChild(comment);

	TiXmlElement * msgs = new TiXmlElement("Messages");
	root->LinkEndChild(msgs);

	msg = new TiXmlElement("Welcome");
	msg->LinkEndChild(new TiXmlText("Welcome to MyApp"));
	msgs->LinkEndChild(msg);

	msg = new TiXmlElement("Farewell");
	msg->LinkEndChild(new TiXmlText("Thank you for using MyApp"));
	msgs->LinkEndChild(msg);

	TiXmlElement * windows = new TiXmlElement("Windows");
	root->LinkEndChild(windows);

	TiXmlElement * window;
	window = new TiXmlElement("Window");
	windows->LinkEndChild(window);
	window->SetAttribute("name", "MainFrame");
	window->SetAttribute("x", 5);
	window->SetAttribute("y", 15);
	window->SetAttribute("w", 400);
	window->SetAttribute("h", 250);

	TiXmlElement * cxn = new TiXmlElement("Connection");
	root->LinkEndChild(cxn);
	cxn->SetAttribute("ip", "192.168.0.1");
	cxn->SetDoubleAttribute("timeout", 123.456); // floating point attrib

	doc.SaveFile(path);

	return 0;
}

RSDLL DWORD RSNewXmlDoc(void)
{
	TiXmlDocument* pXmlDoc = new TiXmlDocument();

	TiXmlDeclaration* decl = new TiXmlDeclaration("1.0", "", "");
	pXmlDoc->LinkEndChild(decl);

	return (DWORD)pXmlDoc;
}

RSDLL DWORD RSSaveXmlDoc(DWORD tiXmlDoc, char* path)
{
	TiXmlDocument* pXmlDoc = (TiXmlDocument*)tiXmlDoc;

	return (DWORD)pXmlDoc->SaveFile(path);
}

RSDLL DWORD RSRemoveXmlDoc(DWORD tiXmlDoc)
{
	TiXmlDocument* pXmlDoc = (TiXmlDocument*)tiXmlDoc;

	if (pXmlDoc != nullptr) {
		delete pXmlDoc;
	}
	
	return 0;

}

RSDLL DWORD RSCreateXmlElement( char* name)
{
	TiXmlElement* pXmlElement = new TiXmlElement(name);
	
	return (DWORD)pXmlElement;
}

RSDLL void RSLinkEndChildFromDoc(DWORD xmlDoc, DWORD childElement)
{
	TiXmlDocument* pXmlDoc = (TiXmlDocument*)xmlDoc;
	TiXmlElement* pXmlChildElement = (TiXmlElement*)childElement;

	pXmlDoc->LinkEndChild(pXmlChildElement);
}

RSDLL void RSLinkEndChild(DWORD parentElement, DWORD childElement)
{
	TiXmlElement* pXmlParentElement = (TiXmlElement*)parentElement;
	TiXmlElement* pXmlChildElement = (TiXmlElement*)childElement;

	pXmlParentElement->LinkEndChild(pXmlChildElement);

}

RSDLL void RSSetAttribute(DWORD xmlElement, int dx, int dy, int index)
{
	TiXmlElement* pXmlElement = (TiXmlElement*)xmlElement;
	
	pXmlElement->SetAttribute("dx", dx);
	pXmlElement->SetAttribute("dy", dy);
	pXmlElement->SetAttribute("index", index);

}

RSDLL int RSLoadXmlFile(DWORD tiXmlDoc, const char* filename)
{
	TiXmlDocument* pXmlDoc = (TiXmlDocument*)tiXmlDoc;

	if (pXmlDoc->LoadFile(filename)) 
	{
		return 0;
	}

	return -1;
}

RSDLL DWORD RSGetRootElement(DWORD tiXmlDoc)
{
	TiXmlDocument* pXmlDoc = (TiXmlDocument*)tiXmlDoc;

	TiXmlElement* rootElement = pXmlDoc->RootElement();

	return (DWORD)rootElement;
}

RSDLL DWORD RSGetTileIds(DWORD xmlRootElement, TileIds data[])
{
	TiXmlElement* rootElement = (TiXmlElement*)xmlRootElement;

	int idx = 0;

	for (TiXmlElement* e = rootElement->FirstChildElement(); e != 0; e = e->NextSiblingElement())
	{
		int dx, dy, index;

		e->Attribute("dx", &dx);
		e->Attribute("dy", &dy);
		e->Attribute("index", &index);

		data[idx].dx = dx;
		data[idx].dy = dy;
		data[idx].index = index;

		idx++;
	}

	return 0;
}