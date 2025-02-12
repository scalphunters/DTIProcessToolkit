if( NOT EXTERNAL_SOURCE_DIRECTORY )
  set( EXTERNAL_SOURCE_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/ExternalSources )
endif()
if( NOT EXTERNAL_BINARY_DIRECTORY )
  set( EXTERNAL_BINARY_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR} )
endif()

# Make sure this file is included only once by creating globally unique varibles
# based on the name of this included file.
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

## External_${extProjName}.cmake files can be recurisvely included,
## and cmake variables are global, so when including sub projects it
## is important make the extProjName and proj variables
## appear to stay constant in one of these files.
## Store global variables before overwriting (then restore at end of this file.)
ProjectDependancyPush(CACHED_extProjName ${extProjName})
ProjectDependancyPush(CACHED_proj ${proj})

# Make sure that the ExtProjName/IntProjName variables are unique globally
# even if other External_${ExtProjName}.cmake files are sourced by
# SlicerMacroCheckExternalProjectDependency
set(extProjName ITK) #The find_package known name
set(proj      ITKv4) #This local name
set(${extProjName}_REQUIRED_VERSION ${${extProjName}_VERSION_MAJOR})  #If a required version is necessary, then set this, else leave blank

#if(${USE_SYSTEM_${extProjName}})
#  unset(${extProjName}_DIR CACHE)
#endif()

# Sanity checks
#if(DEFINED ${extProjName}_DIR AND NOT EXISTS ${${extProjName}_DIR})
#  message(FATAL_ERROR "${extProjName}_DIR variable is defined but corresponds to non-existing directory (${${extProjName}_DIR})")
#endif()
set(${proj}_DEPENDENCIES "")

if(NOT ( DEFINED "USE_SYSTEM_${extProjName}" AND "${USE_SYSTEM_${extProjName}}" ) )
  #message(STATUS "${__indent}Adding project ${proj}")
  # Set dependency list
  if(${PRIMARY_PROJECT_NAME}_BUILD_DICOM_SUPPORT)
    list(APPEND ${proj}_DEPENDENCIES DCMTK)
  endif()

  # Set CMake OSX variable to pass down the external project
  set(CMAKE_OSX_EXTERNAL_PROJECT_ARGS)
  if(APPLE)
    list(APPEND CMAKE_OSX_EXTERNAL_PROJECT_ARGS
      -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
      -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
      -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
  endif()

  if(${PRIMARY_PROJECT_NAME}_BUILD_FFTW_SUPPORT)
    list(APPEND ${proj}_DEPENDENCIES FFTW)
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_TIFF_SUPPORT )
    list(APPEND ${proj}_DEPENDENCIES TIFF)
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_JPEG_SUPPORT )
    list(APPEND ${proj}_DEPENDENCIES JPEG)
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_ZLIB_SUPPORT )
    list(APPEND ${proj}_DEPENDENCIES zlib)
  endif()
  # Include dependent projects if any
  SlicerMacroCheckExternalProjectDependency(${proj})
  set(${proj}_DCMTK_ARGS)
  if(${PRIMARY_PROJECT_NAME}_BUILD_DICOM_SUPPORT)
   set(${proj}_DCMTK_ARGS
      -DDCMTK_DIR:PATH=${DCMTK_DIR}
      -DModule_ITKDCMTK:BOOL=ON
      -DModule_ITKIODCMTK:BOOL=ON
      )
  endif()

  if(${PRIMARY_PROJECT_NAME}_BUILD_FFTW_SUPPORT)
    set(${proj}_FFTWF_ARGS
      -DITK_USE_FFTWF:BOOL=ON
      -DITK_USE_FFTWD:BOOL=ON
      -DFFTW_DIR:PATH=${FFTW_DIR}
      -DFFTW_INCLUDE_PATH:PATH=${FFTW_INCLUDE_PATH}
      -DFFTWD_LIB:PATH=${FFTWD_LIB}
      -DFFTWF_LIB:PATH=${FFTWF_LIB}
      -DFFTWD_THREADS_LIB:PATH=${FFTWD_THREADS_LIB}
      -DFFTWF_THREADS_LIB:PATH=${FFTWF_THREADS_LIB}
      -DITK_USE_SYSTEM_FFTW:BOOL=ON
      )
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_TIFF_SUPPORT )
    set(${proj}_TIFF_ARGS
      -DITK_USE_SYSTEM_TIFF:BOOL=ON
      -DTIFF_LIBRARY:FILEPATH=${TIFF_LIBRARY}
      -DTIFF_INCLUDE_DIR:PATH=${TIFF_INCLUDE_DIR}
       )
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_JPEG_SUPPORT )
    set(${proj}_JPEG_ARGS
      -DITK_USE_SYSTEM_JPEG:BOOL=ON
      -DJPEG_LIBRARY:FILEPATH=${JPEG_LIBRARY}
      -DJPEG_INCLUDE_DIR:PATH=${JPEG_INCLUDE_DIR}
      )
  endif()
  if( ${PRIMARY_PROJECT_NAME}_BUILD_ZLIB_SUPPORT )
    set(${proj}_ZLIB_ARGS
      -DITK_USE_SYSTEM_ZLIB:BOOL=ON
      -DZLIB_INCLUDE_DIR:STRING=${ZLIB_INCLUDE_DIR}
      -DZLIB_LIBRARY:STRING=${ZLIB_LIBRARY}
      )
  endif()
  if( USE_ITK_Module_MGHIO )
    set( ${proj}_CMAKE_ADDITIONAL_OPTIONS
      -DModule_MGHIO:BOOL=ON  # Allow building of the MGHIO classes
      )
  endif()
  set(${proj}_WRAP_ARGS)
  #if(foo)
    #set(${proj}_WRAP_ARGS
    #  -DINSTALL_WRAP_ITK_COMPATIBILITY:BOOL=OFF
    #  -DWRAP_float:BOOL=ON
    #  -DWRAP_unsigned_char:BOOL=ON
    #  -DWRAP_signed_short:BOOL=ON
    #  -DWRAP_unsigned_short:BOOL=ON
    #  -DWRAP_complex_float:BOOL=ON
    #  -DWRAP_vector_float:BOOL=ON
    #  -DWRAP_covariant_vector_float:BOOL=ON
    #  -DWRAP_rgb_signed_short:BOOL=ON
    #  -DWRAP_rgb_unsigned_char:BOOL=ON
    #  -DWRAP_rgb_unsigned_short:BOOL=ON
    #  -DWRAP_ITK_TCL:BOOL=OFF
    #  -DWRAP_ITK_JAVA:BOOL=OFF
    #  -DWRAP_ITK_PYTHON:BOOL=ON
    #  -DPYTHON_EXECUTABLE:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_EXECUTABLE}
    #  -DPYTHON_INCLUDE_DIR:PATH=${${CMAKE_PROJECT_NAME}_PYTHON_INCLUDE}
    #  -DPYTHON_LIBRARY:FILEPATH=${${CMAKE_PROJECT_NAME}_PYTHON_LIBRARY}
    #  )
  #endif()

  # HACK This code fixes a loony problem with HDF5 -- it doesn't
  #      link properly if -fopenmp is used.
  string(REPLACE "-fopenmp" "" ITK_CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
  string(REPLACE "-fopenmp" "" ITK_CMAKE_CXX_FLAGS "${CMAKE_CX_FLAGS}")


  set(${proj}_INSTALL_PATH "${EXTERNAL_BINARY_DIRECTORY}/${proj}-install")
  set(${proj}_CMAKE_OPTIONS
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_EXAMPLES:BOOL=OFF
      -DCMAKE_INSTALL_PREFIX:PATH=${${proj}_INSTALL_PATH}
      -DITK_LEGACY_REMOVE:BOOL=${ITK_LEGACY_REMOVE} # ITKv3 compatibility is required for dwiAtlas to compile and run!
      -DITKV3_COMPATIBILITY:BOOL=${ITKV3_COMPATIBILITY}  # ITKv3 compatibility is required for dwiAtlas to compile and run!
      -DITK_BUILD_DEFAULT_MODULES:BOOL=ON
      -DKWSYS_USE_MD5:BOOL=ON # Required by SlicerExecutionModel
      -DITK_WRAPPING:BOOL=OFF #${BUILD_SHARED_LIBS} ## HACK:  QUICK CHANGE
      -DITK_USE_SYSTEM_DCMTK:BOOL=${${PRIMARY_PROJECT_NAME}_BUILD_DICOM_SUPPORT}
      -DModule_ITKIOPhilipsREC:BOOL=ON
      ${${proj}_TIFF_ARGS}
      ${${proj}_JPEG_ARGS}
      ${${proj}_ZLIB_ARGS}
      ${${proj}_DCMTK_ARGS}
      ${${proj}_WRAP_ARGS}
      ${${proj}_FFTWF_ARGS}
      ${${proj}_FFTWD_ARGS}
      ${${proj}_CMAKE_ADDITIONAL_OPTIONS}
    )
  ### --- End Project specific additions
  set(${proj}_REPOSITORY ${git_protocol}://github.com/InsightSoftwareConsortium/ITK)
  set(${proj}_GIT_TAG c5138560409c75408ff76bccff938f21e5dcafc6)
  set(ITK_VERSION_ID ITK-4.12)

  ExternalProject_Add(${proj}
    GIT_REPOSITORY ${${proj}_REPOSITORY}
    GIT_TAG ${${proj}_GIT_TAG}
    SOURCE_DIR ${EXTERNAL_SOURCE_DIRECTORY}/${proj}
    BINARY_DIR ${proj}-build
    LOG_CONFIGURE 0  # Wrap configure in script to ignore log output from dashboards
    LOG_BUILD     0  # Wrap build in script to to ignore log output from dashboards
    LOG_TEST      0  # Wrap test in script to to ignore log output from dashboards
    LOG_INSTALL   0  # Wrap install in script to to ignore log output from dashboards
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
      ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
      ${COMMON_EXTERNAL_PROJECT_ARGS}
      ${${proj}_CMAKE_OPTIONS}
## We really do want to install in order to limit # of include paths INSTALL_COMMAND ""
    DEPENDS
      ${${proj}_DEPENDENCIES}
  )
  set(${extProjName}_DIR ${EXTERNAL_BINARY_DIRECTORY}/${proj}-install/lib/cmake/${ITK_VERSION_ID})
else()
  if(${USE_SYSTEM_${extProjName}})
    find_package(${extProjName} ${ITK_VERSION_MAJOR} REQUIRED)
    message("USING the system ${extProjName}, set ${extProjName}_DIR=${${extProjName}_DIR}")
  endif()
  # The project is provided using ${extProjName}_DIR, nevertheless since other
  # project may depend on ${extProjName}, let's add an 'empty' one
  SlicerMacroEmptyExternalProject(${proj} "${${proj}_DEPENDENCIES}")
endif()

list(APPEND ${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_VARS ${extProjName}_DIR:PATH)
_expand_external_project_vars()
set(COMMON_EXTERNAL_PROJECT_ARGS ${${CMAKE_PROJECT_NAME}_SUPERBUILD_EP_ARGS})

ProjectDependancyPop(CACHED_extProjName extProjName)
ProjectDependancyPop(CACHED_proj proj)
