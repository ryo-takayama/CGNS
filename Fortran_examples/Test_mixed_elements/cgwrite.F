
        program write_mixed_elements

!	author: Diane Poirier
!	last revised on March 15 2000

! 	This example test the writing of and element section of
!	type MIXED, which includes some NGON_x elements of different size
!	The model is not realistic, as all the data is dummy.

#ifdef WINNT
	include 'cgnswin_f.h'
#endif
	include 'cgnslib_f.h'

	integer index_dim, cell_dim, phys_dim
	integer cg, base, zone, size(3), ier, index, ZoneType
	integer i, j, k, n, pos, coord, element(22), section_no
	character*32 ZoneName, coordname(3)
        double precision data_double(27)
	integer grid_no, count

!       initialize
        ier = 0
	index_dim = 1
	cell_dim=3
	phys_dim=3

!       open CGNS file for writing

        call cg_open_f('Test_V2', MODE_WRITE, cg, ier)
        if (ier .eq. ERROR) call cg_error_exit_f

!*******write CGNSBase
!234567890!234567890!234567890!234567890!234567890!234567890!23456789012
	call cg_base_write_f(cg, 'MixedElementBase', cell_dim, phys_dim, 
     &			     base, ier)
        if (ier .eq. ERROR) call cg_error_exit_f

!*******write only 1 unstructured zone
	zone = 1
	ZoneType=Unstructured
	write(ZoneName,100) 'UnstructuredZone#1'
 100	format(a)
	size(1) = 27		! no of nodes 
	size(2) = 3		! no of elements
	size(3) = 0		! unsorted nodes    

	call cg_zone_write_f(cg, base, 'UnstructuredZone#1', size, 
     &                       ZoneType, index, ier)
        if (ier .eq. ERROR) call cg_error_exit_f

! Name convention
        coordname(1) = 'CoordinateX'
        coordname(2) = 'CoordinateY'
        coordname(3) = 'CoordinateZ'


! Create GridCoordinates_t node
            call cg_grid_write_f(cg,base,index,'GridCoordinates',
     &                         grid_no, ier)
            if (ier.ne. ALL_OK) call cg_error_exit_f

! create coordinate data(10x10x10 box with 3x3x3 equidistant nodes)
        do coord=1,phys_dim
            do 20 k=1, 3
            do 20 j=1, 3
            do 20 i=1, 3
                pos = i + (j-1)*3 + (k-1)*9
                if (coord.eq.1) data_double(pos) = (i-1)*5
                if (coord.eq.2) data_double(pos) = (j-1)*5
                if (coord.eq.3) data_double(pos) = (k-1)*5
 20         continue
!234567890!234567890!234567890!234567890!234567890!234567890!23456789012

! GOTO GridCoordinatesNode & write DataArray
            call cg_goto_f(cg, base, ier, 'Zone_t', zone,
     &                     'GridCoordinates_t', 1, 'end')
            if (ier .eq. ERROR) call cg_error_exit_f

            call cg_array_write_f(coordname(coord), RealDouble, 
     &                            index_dim, size, data_double, ier)
            if (ier .eq. ERROR) call cg_error_exit_f
	enddo	! coord. loop

! Generate dummy elements

	count = 0
! first element HEXA_8
	count = count + 1
	element(count)=HEXA_8
	do i=1,8
	    count = count + 1
	    element(count)=i
	enddo
! second element TETRA_4
	count = count + 1
	element(count)=TETRA_4
	do i=1,4
	    count = count + 1
            element(count)=i
        enddo
! 3rd element NGON_7, so set ElementType to NGON_n+7
	count = count + 1
	element(count)=NGON_n+7
	do i=1,7
            count = count + 1
            element(count)=i
        enddo

!234567890!234567890!234567890!234567890!234567890!234567890!23456789012
! Write MIXED element section
	call cg_section_write_f(cg, base, zone, 'MixedElements', MIXED, 
     &                          1, 3, 0, element, section_no, ier)
	if (ier .eq. ERROR) call cg_error_exit_f

! Write section of 4 NGON_n of 3 nodes 
        count = 0
	do n=1,4
	    count = count + 1
	    element(count)=3
	    do i=1,3
		count = count + 1
		element(count)=10*n+i
	    enddo
	enddo
	call cg_section_write_f(cg, base, zone, 'NGON_n(3)', 
     &                 NGON_n, 1, 4, 0, element, section_no, ier)
	if (ier .eq. ERROR) call cg_error_exit_f

! Write & close CGNS file

	call cg_close_f(cg, ier)
	if (ier.eq. ERROR) call cg_error_exit_f()

	end
