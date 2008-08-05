-- Copyright (C) 2008, The Perl Foundation.
-- $Id$

--[[

lib/gl.lua - OpenGL library

See original on L<http://luagl.wikidot.com/>

]]

require '_helpers'
require 'gl_binding'

module('gl', package.seeall)

-- Accum (op, value) -> none

-- AlphaFunc (func, ref) -> none

-- AreTexturesResident (texturesArray) -> residences

-- ArrayElement (i) -> none

-- Begin (mode) -> none
function Begin (mode)
    if not _helpers.lua_isstring(mode) then
        error "incorrect argument to function 'gl.Begin'"
    end
    gl_binding.glBegin(
       gl_binding._get_gl_enum(mode, "incorrect string argument to function 'gl.Begin'")
    )
end

-- BindTexture (target, texture) -> none

-- Bitmap (xorig, yorig, ymove, bitmap) -> none

-- BlendFunc (sfactor, dfactor) -> none

-- CallList (list) -> none

-- CallLists (listArray) -> none

-- Clear (mask) -> none
function Clear (mask)
    if not _helpers.lua_isstring(mask) then
        error "incorrect argument to function 'gl.Clear'"
    end
    gl_binding.glClear(
       gl_binding._get_gl_enum(mask, "incorrect string argument to function 'gl.Clear'")
    )
end

-- ClearAccum (red, green, blue, alpha) -> none

-- ClearColor (red, green, blue, alpha) -> none

-- ClearDepth (depth) -> none

-- ClearIndex (c) -> none

-- ClearStencil (s) -> none

-- ClipPlane (plane, equationArray) -> none

-- Color (red, green, blue [, alpha]) -> none
-- Color (color) -> none
function Color (...)
    local arg = {...}
    local num_args = #arg
    if _helpers.lua_istable(arg[1]) then
        num_args, array = gl_binding._get_arrayf(arg[1])
        if num_args > 4 then num_args = 4 end
        if num_args == 3 then
            gl_binding.glColor3dv(array)
        else
            gl_binding.glColor4dv(array)
        end
        return
    end
    if num_args > 4 then num_args = 4 end
    for index = 1, num_args do
        if not _helpers.lua_isnumber(arg[index]) then
            error "incorrect argument to function 'gl.Color'"
        end
    end
    if num_args == 3 then
        gl_binding.glColor3d(arg[1], arg[2], arg[3])
    else
        gl_binding.glColor4d(arg[1], arg[2], arg[3], arg[4])
    end
end

-- ColorMask (red, green, blue, alpha) -> none

-- ColorMaterial (face, mode) -> none

-- ColorPointer (colorArray) -> none

-- CopyPixels (x, y, width, height, type) -> none

-- CopyTexImage (level, internalFormat, border, x, y, width[, height]) -> none

-- CopyTexSubImage (level, x, y, xoffset, width[, yoffset, height]) -> none

-- CullFace (mode) -> none

-- DeleteLists (list, range) -> none

-- DeleteTextures (texturesArray) -> none

-- DepthFunc (func) -> none

-- DepthMask (flag) -> none

-- DepthRange (zNear, zFar) -> none

-- Disable (cap) -> none

-- DisableClientState (array) -> none

-- DrawArrays (mode, first, count) -> none

-- DrawBuffer (mode) -> none

-- DrawElements (mode, indicesArray) -> none

-- DrawPixels (width, height, format, pixels) -> none

-- EdgeFlag (flag) -> none

-- EdgeFlagPointer (flagsArray) -> none

-- Enable (cap) -> none

-- EnableClientState (array) -> none

-- End () -> none
function End ()
    gl_binding.glEnd()
end

-- EndList () -> none

-- EvalCoord (u[, v]) -> none
-- EvalCoord (coordArray) -> none

-- EvalMesh (mode, i1, i2[,j1, j2]) -> none

-- EvalPoint (i[, j]) -> none

-- FeedbackBuffer (size, type) -> dataArray

-- Finish () -> none

-- Flush () -> none

-- Fog (pname, param) -> none
-- Fog (pname, paramsArray) -> none

-- FrontFace (mode) -> none

-- Frustum (left, right, bottom, top, zNear, zFar) -> none

-- GenLists (range) -> num

-- GenTextures (n) -> texturesArray

-- Get (pname) -> params

-- GetConst (pname) -> constant string

-- GetArray (pname) -> paramsArray

-- GetClipPlane (plane) -> equationArray

-- GetError () -> error flag

-- GetLight (light, pname) -> paramsArray

-- GetMap (target, query) -> vArray

-- GetMaterial (face, pname) -> paramsArray

-- GetPixelMap (map) -> valuesArray

-- GetPointer (pname, n) -> valuesArray

-- GetPolygonStipple () -> maskArray

-- GetString (name) -> string

-- GetTexEnv (pname) -> paramsArray

-- GetTexGen (coord, pname) -> paramsArray

-- GetTexImage (target, level, format) -> pixelsArray

-- GetTexLevelParameter (target, level, pname) -> param

-- GetTexParameter (target, pname) -> paramsArray

-- Hint (target, mode) -> none

-- Index (c) -> none

-- IndexMask (mask) -> none

-- IndexPointer (indexArray) -> none

-- InitNames () -> none

-- IsEnabled (cap) -> true/false

-- IsList (list) -> true/false

-- IsTexture (texture) -> true/false

-- Light (light, pname, param) -> none
-- Light (light, pname, paramsArray) -> none

-- LightModel (pname, param) -> none
-- LightModel (pname, paramsArray) -> none

-- LineStipple (factor, pattern) -> none

-- LineWidth (width) -> none

-- ListBase (base) -> none

-- LoadIdentity () -> none

-- LoadMatrix (mArray) -> none

-- LoadName (name) -> none

-- LogicOp (opcode) -> none

-- Map (target, u1, u2, ustride, pointsArray) -> none
-- Map (target, u1, u2, ustride, v1, v2, vstride, pointsArray) -> none

-- MapGrid (un, u1, u2[, vn, v1, v2]) -> none

-- Material (face, pname, param) -> none

-- MatrixMode (mode) -> none

-- MultMatrix (mArray) -> none

-- NewList (list, mode) -> none

-- Normal (nx, ny, nz) -> none
-- Normal (nArray) -> none

-- NormalPointer (normalArray) -> none

-- Ortho (left, right, bottom, top, zNear, zFar) -> none

-- PassThrough (token) -> none

-- PixelMap (map, valuesArray) -> none

-- PixelStore (pname, param) -> none

-- PixelTransfer (pname, param) -> none

-- PixelZoom (xfactor, yfactor) -> none

-- PointSize (size) -> none

-- PolygonMode (face, mode) -> none

-- PolygonOffset (factor, units) -> none

-- PolygonStipple (maskArray) -> none

-- PopAttrib () -> none

-- PopClientAttrib () -> none

-- PopMatrix () -> none

-- PopName () -> none

-- PrioritizeTextures (texturesArray, prioritiesArray) -> none

-- PushAttrib (mask) -> none

-- PushClientAttrib (mask) -> none

-- PushMatrix () -> none

-- PushName (GLuint name) -> none

-- RasterPos (x, y[, z, w]) -> none
-- RasterPos (vArray) -> none

-- ReadBuffer (mode) -> none

-- ReadPixels (x, y, width, height, format, pixelsArray) -> none

-- Rect (x1, y1, x2, y2) -> none
-- Rect (v1, v2) -> none

-- RenderMode (mode) -> none

-- Rotate (angle, x, y, z) -> none
function Rotate (angle, x, y, z)
    if not (_helpers.lua_isnumber(angle)
        and _helpers.lua_isnumber(x)
        and _helpers.lua_isnumber(y)
        and _helpers.lua_isnumber(z)) then
        error "incorrect argument to function 'gl.Rotate'"
    end
    gl_binding.glRotated(angle, x, y, z)
end

-- Scale (x, y, z) -> none

-- Scissor (x, y, width, height) -> none

-- SelectBuffer (size) -> SelectArray

-- ShadeModel (mode) -> none

-- StencilFunc (func, ref, mask) -> none

-- StencilMask (mask) -> none

-- StencilOp (fail, zfail, zpass) -> none

-- TexCoord (s[, t, r, q]) -> none
-- TexCoord (vArray) -> none

-- TexCoordPointer(vArray) -> none

-- TexEnv (pname, param) -> none
-- TexEnv (pname, paramsArray) -> none

-- TexGen (coord, pname, param) -> none
-- TexGen (coord, pname, paramsArray) -> none

-- TexImage(level, internalformat, format, pixels) -> none

-- TexSubImage (level, format, pixels, xoffset) -> none
-- TexSubImage (level, format, pixels, xoffset, yoffset) -> none

-- TexParameter (target, pname, param) -> none
-- TexParameter (target, pname, paramsArray) -> none

-- Translate (x, y, z) -> none

-- Vertex (x, y, [z, w]) -> none
-- Vertex (v) -> none
function Vertex (...)
    local arg = {...}
    local num_args = #arg
    local v
    if num_args == 0 then
        error "incorrect argument to function 'gl.Vertex'"
    end
    if _helpers.lua_istable(arg[1]) then
        num_args, v = gl_binding._get_arrayf(arg[1])
    else
        if num_args < 2 then
            error "incorrect argument to function 'gl.Vertex'"
        end
        for index = 1, num_args do
            if not _helpers.lua_isnumber(arg[index]) then
                error "incorrect argument to function 'gl.Vertex'"
            end
        end
        num_args, v = gl_binding._get_arrayf(arg)
    end
    if num_args == 2 then
        gl_binding.glVertex2dv(v)
    elseif num_args == 3 then
        gl_binding.glVertex3dv(v)
    else
        gl_binding.glVertex4dv(v)
    end
end

-- VertexPointer (vertexArray) -> none

-- Viewport (x, y, width, height) -> none

