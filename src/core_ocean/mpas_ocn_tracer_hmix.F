! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.com/license.html
!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
!
!  ocn_tracer_hmix
!
!> \brief MPAS ocean horizontal tracer mixing driver
!> \author Doug Jacobsen, Mark Petersen, Todd Ringler
!> \date   September 2011
!> \details
!>  This module contains the main driver routine for computing 
!>  horizontal mixing tendencies.  
!>
!>  It provides an init and a tend function. Each are described below.
!
!-----------------------------------------------------------------------

module ocn_tracer_hmix

   use mpas_grid_types
   use mpas_configure
   use mpas_timer
   use ocn_tracer_hmix_del2
   use ocn_tracer_hmix_del4

   implicit none
   private
   save

   !--------------------------------------------------------------------
   !
   ! Public parameters
   !
   !--------------------------------------------------------------------

   !--------------------------------------------------------------------
   !
   ! Public member functions
   !
   !--------------------------------------------------------------------

   public :: ocn_tracer_hmix_tend, &
             ocn_tracer_hmix_init

   !--------------------------------------------------------------------
   !
   ! Private module variables
   !
   !--------------------------------------------------------------------

   logical :: tracerHmixOn
   type (timer_node), pointer :: del2Timer, del4Timer


!***********************************************************************

contains

!***********************************************************************
!
!  routine ocn_tracer_hmix_tend
!
!> \brief   Computes tendency term for horizontal tracer mixing
!> \author  Doug Jacobsen, Mark Petersen, Todd Ringler
!> \date    September 2011
!> \details 
!>  This routine computes the horizontal mixing tendency for tracer
!>  based on current state and user choices of mixing parameterization.
!>  Multiple parameterizations may be chosen and added together.  These
!>  tendencies are generally computed by calling the specific routine
!>  for the chosen parameterization, so this routine is primarily a
!>  driver for managing these choices.
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_hmix_tend(mesh, layerThicknessEdge, tracers, tend, err)!{{{

      !-----------------------------------------------------------------
      !
      ! input variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:), intent(in) :: &
         layerThicknessEdge    !< Input: thickness at edge

      type (mesh_type), intent(in) :: &
         mesh          !< Input: mesh information

      real (kind=RKIND), dimension(:,:,:), intent(in) :: &
        tracers !< Input: tracer quantities

      !-----------------------------------------------------------------
      !
      ! input/output variables
      !
      !-----------------------------------------------------------------

      real (kind=RKIND), dimension(:,:,:), intent(inout) :: &
         tend          !< Input/Output: velocity tendency

      !-----------------------------------------------------------------
      !
      ! output variables
      !
      !-----------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      !-----------------------------------------------------------------
      !
      ! local variables
      !
      !-----------------------------------------------------------------

      integer :: err1, err2

      !-----------------------------------------------------------------
      !
      ! call relevant routines for computing tendencies
      ! note that the user can choose multiple options and the 
      !   tendencies will be added together
      !
      !-----------------------------------------------------------------

      if(.not.tracerHmixOn) return

      call mpas_timer_start("del2", .false., del2Timer)
      call ocn_tracer_hmix_del2_tend(mesh, layerThicknessEdge, tracers, tend, err1)
      call mpas_timer_stop("del2", del2Timer)
      call mpas_timer_start("del4", .false., del4Timer)
      call ocn_tracer_hmix_del4_tend(mesh, layerThicknessEdge, tracers, tend, err2)
      call mpas_timer_stop("del4", del4Timer)

      err = ior(err1, err2)

   !--------------------------------------------------------------------

   end subroutine ocn_tracer_hmix_tend!}}}

!***********************************************************************
!
!  routine ocn_tracer_hmix_init
!
!> \brief   Initializes ocean tracer horizontal mixing quantities
!> \author  Doug Jacobsen, Mark Petersen, Todd Ringler
!> \date    September 2011
!> \details 
!>  This routine initializes a variety of quantities related to 
!>  horizontal velocity mixing in the ocean. Since a variety of 
!>  parameterizations are available, this routine primarily calls the
!>  individual init routines for each parameterization. 
!
!-----------------------------------------------------------------------

   subroutine ocn_tracer_hmix_init(err)!{{{

   !--------------------------------------------------------------------

      !-----------------------------------------------------------------
      !
      ! call individual init routines for each parameterization
      !
      !-----------------------------------------------------------------

      integer, intent(out) :: err !< Output: error flag

      integer :: err1, err2

      tracerHmixOn = .true.

      if(config_disable_tr_hmix) tracerHmixOn = .false.
      call ocn_tracer_hmix_del2_init(err1)
      call ocn_tracer_hmix_del4_init(err2)

      err = ior(err1, err2)

   !--------------------------------------------------------------------

   end subroutine ocn_tracer_hmix_init!}}}

!***********************************************************************

end module ocn_tracer_hmix

!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
