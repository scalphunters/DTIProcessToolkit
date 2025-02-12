/*=========================================================================

  Program:   Diffusion Applications
  Module:    $HeadURL: http://svn.slicer.org/Slicer3/trunk/Applications/CLI/DiffusionApplications/ResampleDTI/itkDiffusionTensor3DZeroCorrection.h $
  Language:  C++
  Date:      $Date: 2010-03-15 18:00:34 -0400 (Mon, 15 Mar 2010) $
  Version:   $Revision: 12353 $

  Copyright (c) Brigham and Women's Hospital (BWH) All Rights Reserved.

  See License.txt or http://www.slicer.org/copyright/copyright.txt for details.

==========================================================================*/
#ifndef __itkDiffusionTensor3DZeroCorrectionFilter_h
#define __itkDiffusionTensor3DZeroCorrectionFilter_h

#include "itkUnaryFunctorImageFilter.h"
#include "vnl/vnl_math.h"
#include <itkMatrix.h>
#include "itkDiffusionTensor3DExtended.h"
#include "define.h"

namespace itk
{

/** \class DiffusionTensor3DZeroCorrectionFilter
 *
 * This filter is templated over the pixel type of the input image
 * and the pixel type of the output image.
 *
 * The filter will walk over all the pixels in the input image, and for
 * each one of them it will do the following:
 *
 * - cast the pixel value to \c DiffusionTensor3DExtended<double>,
 * - Compute the eigenvalues and the eigenvectors
 * - Set negative eigenvalues to zero
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
class DiffusionTensor3DZero
{
public:
  DiffusionTensor3DZero()
  {
  }

  ~DiffusionTensor3DZero()
  {
  }

  bool operator!=( const DiffusionTensor3DZero & other ) const
  {
    return *this != other;
  }

  bool operator==( const DiffusionTensor3DZero & other ) const
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
      mat[i][i] = ( eigenValues[i] <= 0 ? ZERO : eigenValues[i] );
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
class DiffusionTensor3DZeroCorrectionFilter :
  public
  UnaryFunctorImageFilter<TInputImage, TOutputImage,
                          Functor::DiffusionTensor3DZero<
                            typename TInputImage::PixelType::ComponentType,
                            typename TOutputImage::PixelType::ComponentType> >
{
public:
  /** Standard class typedefs. */
  typedef DiffusionTensor3DZeroCorrectionFilter Self;
  typedef UnaryFunctorImageFilter<TInputImage, TOutputImage,
                                  Functor::DiffusionTensor3DZero<typename TInputImage::PixelType,
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
  DiffusionTensor3DZeroCorrectionFilter()
  {
  }

  virtual ~DiffusionTensor3DZeroCorrectionFilter()
  {
  }

private:
  DiffusionTensor3DZeroCorrectionFilter( const Self & ); // purposely not implemented
  void operator=( const Self & );                        // purposely not implemented

};

} // end namespace itk

#endif
