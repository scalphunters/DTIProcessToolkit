/*=========================================================================

  Program:   Diffusion Applications
  Module:    $HeadURL: http://svn.slicer.org/Slicer3/trunk/Applications/CLI/DiffusionApplications/ResampleDTI/itkDiffusionTensor3DAbsCorrection.h $
  Language:  C++
  Date:      $Date: 2008-11-25 14:23:08 -0500 (Tue, 25 Nov 2008) $
  Version:   $Revision: 7976 $

  Copyright (c) Brigham and Women's Hospital (BWH) All Rights Reserved.

  See License.txt or http://www.slicer.org/copyright/copyright.txt for details.

==========================================================================*/
#ifndef __itkDiffusionTensor3DAbsCorrectionFilter_h
#define __itkDiffusionTensor3DAbsCorrectionFilter_h

#include "itkUnaryFunctorImageFilter.h"
#include "vnl/vnl_math.h"
#include <itkMatrix.h>
#include "itkDiffusionTensor3DExtended.h"

namespace itk
{

/** \class DiffusionTensor3DAbsCorrectionFilter
 * \brief Computes pixel-wise the absolute value of the diffusion tensor eigenvalues.
 *
 * This filter is templated over the pixel type of the input image
 * and the pixel type of the output image.
 *
 * The filter will walk over all the pixels in the input image, and for
 * each one of them it will do the following:
 *
 * - cast the pixel value to \c DiffusionTensor3DExtended<double>,
 * - Compute the eigenvalues and the eigenvectors
 * - Set eigenvalues to their absolute value
 * - store the casted value into the output image.
 *
 * The filter expect both images to have the same dimension (e.g. both 2D,
 * or both 3D, or both ND).
 * The filter needs DiffusionTensor3D images to work
 *
 */
namespace Functor
{

template <class TInput, class TOutput>
class DiffusionTensor3DAbs
{
public:
  DiffusionTensor3DAbs()
  {
  }

  ~DiffusionTensor3DAbs()
  {
  }

  bool operator!=( const DiffusionTensor3DAbs & other ) const
  {
    return *this != other;
  }

  bool operator==( const DiffusionTensor3DAbs & other ) const
  {
    return !( *this != other );
  }

  inline DiffusionTensor3D<TOutput> operator()
    ( const DiffusionTensor3D<TInput> & A )
  {
    DiffusionTensor3D<TOutput> tensor;
    Matrix<double, 3, 3>       mat;
    Matrix<double, 3, 3>       matcorrect;
    typename DiffusionTensor3DExtended<double>::EigenValuesArrayType eigenValues;
    typename DiffusionTensor3DExtended<double>::EigenVectorsMatrixType eigenVectors;
    DiffusionTensor3DExtended<double> tensorDouble;
    tensorDouble = ( DiffusionTensor3DExtended<TInput> )A;
    tensorDouble.ComputeEigenAnalysis( eigenValues, eigenVectors );
    for( int i = 0; i < 3; i++ )
      {
      mat[i][i] = ( eigenValues[i] < 0 ? -eigenValues[i] : eigenValues[i] );
      }
    eigenVectors = eigenVectors.GetTranspose();
    matcorrect = eigenVectors * mat * eigenVectors.GetInverse();
    tensorDouble.SetTensorFromMatrix( matcorrect );
    for( int i = 0; i < 6; i++ )
      {
      tensor[i] = ( TOutput ) tensorDouble[i];
      }
    return tensor;
  }

};
} // end of Functor namespace

template <class TInputImage, class TOutputImage>
class DiffusionTensor3DAbsCorrectionFilter :
  public
  UnaryFunctorImageFilter<TInputImage, TOutputImage,
                          Functor::DiffusionTensor3DAbs<
                            typename TInputImage::PixelType::ComponentType,
                            typename TOutputImage::PixelType::ComponentType> >
{
public:
  /** Standard class typedefs. */
  typedef DiffusionTensor3DAbsCorrectionFilter Self;
  typedef UnaryFunctorImageFilter<TInputImage, TOutputImage,
                                  Functor::DiffusionTensor3DAbs<typename TInputImage::PixelType,
                                                                typename TOutputImage::PixelType> >  Superclass;
  typedef SmartPointer<Self>       Pointer;
  typedef SmartPointer<const Self> ConstPointer;

  /** Method for creation through the object factory. */
  itkNewMacro( Self );

#ifdef ITK_USE_CONCEPT_CHECKING
  /** Begin concept checking */
  itkConceptMacro( InputTensorTypeCheck,
                   ( Concept::SameType<DiffusionTensor3D<typename TInputImage::PixelType::ComponentType>,
                                       typename TInputImage::PixelType> ) );
  itkConceptMacro( OutputTensorTypeCheck,
                   ( Concept::SameType<DiffusionTensor3D<typename TOutputImage::PixelType::ComponentType>,
                                       typename TOutputImage::PixelType> ) );

  /** End concept checking */
#endif
protected:
  DiffusionTensor3DAbsCorrectionFilter()
  {
  }

  virtual ~DiffusionTensor3DAbsCorrectionFilter()
  {
  }

private:
  DiffusionTensor3DAbsCorrectionFilter( const Self & ); // purposely not implemented
  void operator=( const Self & );                       // purposely not implemented

};

} // end namespace itk

#endif
