<?xml version='1.0'?>
<xsl:stylesheet 
  xmlns:past="http://www.parrotcode.org/PAST-0.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0" >
<!--

$Id$

This transformation takes an abstract syntax tree as generated 
by phc_xml_to_past_xml.xsl. It generates a PIR-script that creates
a PAST data structure and runs it with the help of a PCT::HLLCompiler.

-->
<xsl:output method='text' />

<xsl:template match="/past:Stmts" >

# Do not edit this file.                                          
# This file has been generated by past_xml_to_past_nqp.xsl
                                                                  
sub php_entry () {
                                                                  
  PAST::Stmts.new( 
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates /> );

}
                                                                  
</xsl:template>


<xsl:template match=" past:Op | past:Val | past:Var | past:Block" >

  <xsl:choose>
    <xsl:when test="name() = 'past:Block'" >PAST::Block</xsl:when>
    <xsl:when test="name() = 'past:Exp'"   >PAST::Exp</xsl:when>
    <xsl:when test="name() = 'past:Op'"    >PAST::Op</xsl:when>
    <xsl:when test="name() = 'past:Stmt'"  >PAST::Stmt</xsl:when>
    <xsl:when test="name() = 'past:Stmts'" >PAST::Stmts</xsl:when>
    <xsl:when test="name() = 'past:Var'"   >PAST::Var</xsl:when>
    <xsl:when test="name() = 'past:Val'"   >PAST::Val</xsl:when>
  </xsl:choose>.new( 
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates /> ),

</xsl:template>

<!-- handle attributes -->
<xsl:template match="@value">
  <xsl:choose>
    <xsl:when test="../@encoding = 'base64'" >
      :<xsl:value-of select="name()" />( decode_base64( '<xsl:value-of select="." />' ) ),
    </xsl:when>
    <xsl:otherwise>
      :<xsl:value-of select="name()" />( '<xsl:value-of select="." />' ),                              
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="@encoding">
</xsl:template>

<xsl:template match="@*">
  :<xsl:value-of select="name()" />( '<xsl:value-of select="." />' ),                              
</xsl:template>

</xsl:stylesheet>
