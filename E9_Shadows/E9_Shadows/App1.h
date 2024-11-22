// Application.h
#ifndef _APP1_H
#define _APP1_H

// Includes
#include "DXF.h"	// include dxframework
#include "TextureShader.h"
#include "ShadowShader.h"
#include "DepthShader.h"
#include "LightShader.h"

class App1 : public BaseApplication
{
public:

	App1();
	~App1();
	void init(HINSTANCE hinstance, HWND hwnd, int screenWidth, int screenHeight, Input* in, bool VSYNC, bool FULL_SCREEN);

	bool frame();

protected:
	bool render();
	void depthPass();
	void finalPass();
	void gui();

private:
	TextureShader* textureShader;
	PlaneMesh* mesh;
	//SphereMesh* mesh2;
	//CubeMesh* mesh3;

	Light* light;
	Light* light2;
	AModel* model;
	ShadowShader* shadowShader;
	DepthShader* depthShader;
	LightShader* lightShader;

	float rotation = 0.1f;

	ShadowMap* shadowMap;
	ShadowMap* shadowMap2;
};

#endif