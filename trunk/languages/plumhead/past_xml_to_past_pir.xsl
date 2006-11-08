<?xml version='1.0'?>
<xsl:stylesheet 
  xmlns:past="http://www.parrotcode.org/PAST-0.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  version="1.0"
>
<!--

$Id$

This transformation takes an abstract syntax tree as generated 
by phc_xml_to_past_xml.xsl. It generates a script in PIR that creates
a PAST and runs the PAST with help of the parrot compiler tools.

-->
<xsl:output method='text' />

<xsl:template match="/" >

# Do not edit this file.                                          
# This file has been generated by past_xml_to_past_pir.xsl
                                                                  
.sub plumhead :main                                                     

  load_bytecode 'PAST.pbc'                                        
  load_bytecode 'languages/punie/lib/POST.pir'                    
  load_bytecode 'languages/punie/lib/PunieOpLookup.pir'
  load_bytecode 'languages/punie/lib/OSTGrammar.pir'              
  load_bytecode 'MIME/Base64.pbc'              
                                                                  
  # phc encodes most but not all strings in base64
  .local pmc decode_base64
  decode_base64 = get_global [ "MIME"; "Base64" ], 'decode_base64'
    
  # The root node of PAST.
  # It will receive another PAST::Stmts node as daughter 
  .local pmc past_node_<xsl:value-of select="generate-id(.)" />                                                  
  past_node_<xsl:value-of select="generate-id(.)" /> = new 'PAST::Stmts'                                       
  
  <xsl:apply-templates />

  # say 'AST tree dump:'                                          
  # past_node_<xsl:value-of select="generate-id(.)" />.dump()                                                  
                                                                  
  # Compile the abstract syntax tree                              
  # down to an opcode syntax tree                                 
  .local string ost_tg_src                                          
  .local pmc tge_compiler                                           
  .local pmc ost_grammar, ost_builder, ost                          
  tge_compiler = new 'TGE::Compiler'                              
  ost_tg_src = _slurp_file('languages/punie/lib/OSTGrammar.tg')   
  ost_grammar = tge_compiler.'compile'(ost_tg_src)                
  ost_builder = ost_grammar.apply(past_node_<xsl:value-of select="generate-id(.)" />)                          
  ost = ost_builder.get('result')                                 
  unless ost goto ERR_NO_OST                                      
                                                                  
  # Compile the OST down to PIR                                   
  .local string pir_tg_src                                          
  .local pmc pir_grammar, pir_builder, pir                          
  pir_tg_src = _slurp_file('languages/punie/lib/PIRGrammar.tg')   
  pir_grammar = tge_compiler.'compile'(pir_tg_src)                
  pir_builder = pir_grammar.apply(ost)                            
  pir = pir_builder.get('result')                                 
  unless pir goto ERR_NO_PIR                                      
                                                                  
  # execute                                                       
  .local pmc pir_compiler, pir_compiled                             
  pir_compiler = compreg 'PIR'                                    
  pir_compiled = pir_compiler( pir )                              
  pir_compiled()                                                  
  say ''                                                          
  goto CLEANUP                                                    
                                                                  
  ERR_NO_OST:                                                     
    say 'Unable to construct OST.'                                
    goto CLEANUP                                                  
                                                                  
  ERR_NO_PIR:                                                     
    say 'Unable to construct PIR.'                                
    goto CLEANUP                                                  
                                                                  
  CLEANUP:                                                        
.end                                                              
                                                                  
# helpers

.sub _slurp_file                                                  
  .param string filename                                          
                                                                  
  .local pmc filehandle                                             
  .local string content                                             
  filehandle = open filename, '&lt;'                                 
  unless filehandle goto ERR_NO_FILE                              
  content = read filehandle, 65535                                
  close filehandle                                                
                                                                  
  .return ( content )                                             
                                                                  
  ERR_NO_FILE:                                                    
    print 'Unable to open file: '                                 
    say filename                                                  
    end                                                           
                                                                  
.end                                                              
                                                                  
</xsl:template>

<xsl:template match="past:Stmts | past:Stmt | past:Op | past:Exp | past:Val" >

  # start of generic node
  .local pmc past_node_<xsl:value-of select="generate-id(.)" />                                                  
  past_node_<xsl:value-of select="generate-id(.)" /> = new '<xsl:choose>
    <xsl:when test="name() = 'past:Stmts'" >PAST::Stmts</xsl:when>
    <xsl:when test="name() = 'past:Stmt'"  >PAST::Stmt</xsl:when>
    <xsl:when test="name() = 'past:Op'"    >PAST::Op</xsl:when>
    <xsl:when test="name() = 'past:Exp'"   >PAST::Exp</xsl:when>
                                                            </xsl:choose>'
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates />
  past_node_<xsl:value-of select="generate-id(..)" />.'add_child'( past_node_<xsl:value-of select="generate-id(.)" /> )      
  null past_node_<xsl:value-of select="generate-id(.)" />
  # end of generic node

</xsl:template>

<xsl:template match="past:Val">

  # start of past:Val
  <xsl:choose>
    <xsl:when test="@valtype = 'strqq'" >
      .local string val_<xsl:value-of select="generate-id(.)" />
      <xsl:choose>
        <xsl:when test="@encoding = 'base64'" >
          val_<xsl:value-of select="generate-id(.)" /> = decode_base64( "<xsl:value-of select="." />" )
          val_<xsl:value-of select="generate-id(.)" /> = escape val_<xsl:value-of select="generate-id(.)" />
        </xsl:when>
        <xsl:otherwise>
          val_<xsl:value-of select="generate-id(.)" /> = "<xsl:value-of select="." />"
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@valtype = 'int'" >
      .local int val_<xsl:value-of select="generate-id(.)" />
      val_<xsl:value-of select="generate-id(.)" /> = <xsl:value-of select="." />
    </xsl:when>
    <xsl:when test="@valtype = 'num'" >
      .local num val_<xsl:value-of select="generate-id(.)" />
      val_<xsl:value-of select="generate-id(.)" /> = <xsl:value-of select="." />
    </xsl:when>
  </xsl:choose>

  .local pmc past_node_<xsl:value-of select="generate-id(.)" />
  past_node_<xsl:value-of select="generate-id(.)" /> = new 'PAST::Val'                             
  past_node_<xsl:value-of select="generate-id(.)" />.value( val_<xsl:value-of select="generate-id(.)" /> ) 
  <xsl:apply-templates select="@*"/>

  past_node_<xsl:value-of select="generate-id(..)" />.'add_child'( past_node_<xsl:value-of select="generate-id(.)" /> )      
  # end of past:Val

</xsl:template>

<!-- handle attributes -->
<xsl:template match="@op">
  past_node_<xsl:value-of select="generate-id(..)" />.'op'( '<xsl:value-of select="." />' )                              
</xsl:template>
<xsl:template match="@valtype">
  past_node_<xsl:value-of select="generate-id(..)" />.'valtype'( '<xsl:value-of select="." />' )
</xsl:template>
<xsl:template match="@encoding">
</xsl:template>

</xsl:stylesheet>
