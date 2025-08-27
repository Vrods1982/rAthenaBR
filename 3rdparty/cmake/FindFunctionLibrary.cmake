# - Verifica qual biblioteca é necessária para linkar uma função C
# find_function_library( <função> <variável> [<biblioteca> ...] )
#
# Verifica qual biblioteca fornece a <função>.
# Define <variável> como 0 se encontrada nas bibliotecas globais.
# Define <variável> como o caminho da biblioteca se encontrada nas bibliotecas fornecidas.
# Gera um FATAL_ERROR se não for encontrada.
#
# As seguintes variáveis podem ser definidas antes de chamar este macro para
# modificar a forma como a verificação é executada:
#
#  CMAKE_REQUIRED_FLAGS = string de flags da linha de comando de compilação
#  CMAKE_REQUIRED_DEFINITIONS = lista de macros a serem definidas (-DFOO=bar)
#  CMAKE_REQUIRED_INCLUDES = lista de diretórios de inclusão
#  CMAKE_REQUIRED_LIBRARIES = lista de bibliotecas para linkar
include( CheckFunctionExists )

macro( find_function_library FUNC VAR )
	if( "${VAR}" MATCHES "^${VAR}$" )
		CHECK_FUNCTION_EXISTS( ${FUNC} ${VAR} )
		if( ${VAR} )
			message( STATUS "Found ${FUNC} in global libraries" )
			set( ${VAR} 0 CACHE INTERNAL "Found ${FUNC} in global libraries" )# global
		else()
			foreach( LIB IN ITEMS ${ARGN} )
				message( STATUS "Looking for ${FUNC} in ${LIB}" )
				find_library( ${LIB}_LIBRARY ${LIB} )
				mark_as_advanced( ${LIB}_LIBRARY )
				if( ${LIB}_LIBRARY )
					unset( ${VAR} CACHE )
					set( CMAKE_REQUIRED_LIBRARIES ${${LIB}_LIBRARY} )
					CHECK_FUNCTION_EXISTS( ${FUNC} ${VAR} )
					set( CMAKE_REQUIRED_LIBRARIES )
					if( ${VAR} )
						message( STATUS "Found ${FUNC} in ${LIB}: ${${LIB}_LIBRARY}" )
						set( ${VAR} ${${LIB}_LIBRARY} CACHE INTERNAL "Found ${FUNC} in ${LIB}" )# lib
						break()
					endif()
				endif()
			endforeach()
			if( NOT ${VAR} )
				message( FATAL_ERROR "Function ${FUNC} not found" )
			endif()
		endif()
	endif()
endmacro( find_function_library )

