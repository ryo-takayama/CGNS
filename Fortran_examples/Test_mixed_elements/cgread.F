
        program read_mixed_elements

!	author: Diane Poirier
!       last revised on April 19 2000

! 	This example reads an unstructured zone mixed element section

#ifdef WINNT
	include 'cgnswin_f.h'
#endif
        include 'cgnslib_f.h'

        parameter (NNODES=27, NELEMENTS=3)

	integer Cdim, Pdim, Idim, ier, count
	integer cg, base, zone, size(3), ZoneType
	integer nbases, nzones, ncoords, nsections
	integer i, n, sect, range_min(3), range_max(3)
	integer start, end, nbndry, type
        integer elements(1000), ElementDataSize
	character*32 coordname(3), filename, nodename
        double precision data_double(NNODES)

!       initialize
        ier = 0

!       write(6,100) 'Input filename'
!       read(5,100) filename
!       open CGNS file for reading
        write(filename,100)'Test_V2'

 	call cg_open_f(filename, MODE_READ, cg, ier)
        if (ier .eq. ERROR) call cg_error_exit_f
	write(6,100)'File Opened and Read '

!*******read CGNSBase
	call cg_nbases_f(cg, nbases, ier)
	if (ier .eq. ERROR) call cg_error_exit_f
	if (nbases .gt. 1) then
	    write(6,100)'This program reads only the first base'
	else if (nbases .le. 0) then
	    write(6,100)'No base found'
	    goto 9999
	endif
	base = 1
	call cg_base_read_f(cg, base, nodename, Cdim, Pdim, ier)
        if (ier .eq. ERROR) call cg_error_exit_f

        write(6,100)'*** CGNSBase_t node ***'
        write(6,103)'Name= ',nodename
        write(6,104)'CellDimension=',Cdim
        write(6,105)'PhysDimension=',Pdim

! ******read CGNSBase substructure: Zone
	call cg_nzones_f(cg, base, nzones, ier)
	if (ier .eq. ERROR) call cg_error_exit_f

	if (nzones .gt. 1) then
	    write(6,100)'This program reads only the first zone'
	else if (nzones .le. 0) then
	    write(6,100)'No zone found'
	    goto 9999
	endif
	zone = 1

        call cg_zone_read_f(cg,base,zone, nodename,size,ier)
	if (ier .eq. ERROR) call cg_error_exit_f

	call cg_zone_type_f(cg, base, zone, ZoneType, ier)
	if (ier .eq. ERROR) call cg_error_exit_f

	Idim=Cdim
	if (ZoneType .eq. Unstructured) Idim=1

        write(6,100)'*** Zone_t node ***'
        write(6,103)'Name= ',nodename
        write(6,103)'ZoneType= ',ZoneTypeName(ZoneType)
        write(6,106)'Size= ', (size(i),i=1,Idim*3)

! COORDINATES
	call cg_ncoords_f(cg, base, zone, ncoords, ier)
	if (ier .eq. ERROR) call cg_error_exit_f
	write(6,104)'ncoords=',ncoords

	write(6,104)'Idim=',Idim
	do i=1, Idim
	    range_min(i)=1
	    range_max(i)=size(i)
        enddo
!234567890!234567890!234567890!234567890!234567890!234567890!23456789012
	write(6,107) 'range:',(range_min(i),i=1,Idim),
     &                                 (range_max(i),i=1,Idim)
! Name convention
        coordname(1) = 'CoordinateX'
        coordname(2) = 'CoordinateY'
        coordname(3) = 'CoordinateZ'
	do i=1, Pdim
	    call cg_coord_read_f(cg, base, zone, coordname(i), 
     &            RealDouble, range_min, range_max, data_double, ier)
	    if (ier .eq. ERROR) call cg_error_exit_f 
	    write(6,103)coordname(i)
	    write(6,109)'first point:',data_double(1)
	    write(6,109)'last point :',data_double(size(1))
	enddo

! ELEMENTS
	write(6,102)'*** Elements_t Nodes ***'
	call cg_nsections_f(cg, base, zone, nsections, ier)
	if (ier .eq. ERROR) call cg_error_exit_f

	do sect=1, nsections

! Read all element info:
	    call cg_section_read_f(cg, base, zone, sect,
     &              nodename, type, start, end, nbndry, 
     &              parent_flag, ier)
	    if (ier .eq. ERROR) call cg_error_exit_f

	    call cg_ElementDataSize_f(cg, base, zone, sect, 
     &                                ElementDataSize, ier)
	    if (ier .eq. ERROR) call cg_error_exit_f
	    
	    call cg_elements_read_f(cg, base, zone, sect,
     &                 elements, parent_data, ier)
	    if (ier .eq. ERROR) call cg_error_exit_f


! Print out element info:
	    write(6,113)'  *** Section ',sect,' ***'
	    write(6,103)'Name= ',nodename
            write(6,108)'Range= ',start,end
            if (nbndry .ne. 0) write(6,103)'Sorted elements'

            call cg_npe_f(type, npe, ier)
            if (ier .eq. ERROR) call cg_error_exit_f
	    
	    write(6,107) 'ElementDataSize =',ElementDataSize
            write(6,103) 'Section Element Type= ',
     &                             ElementTypeName(type)

	    nelem = end-start+1
	    write(6,103)'Element Connectivity:'
	    if (type .lt. MIXED) then
	        do i=1, nelem
	            write(6,110)(elements((i-1)*npe+n),n=1,npe)
	    	enddo
	    elseif (type .eq. MIXED) then
		count = 0
	        do i=1, nelem
		    count = count + 1
		    type = elements(count)
		    if (type .gt. NGON_n) then
			npe = type - NGON_n
			write(6,111) 
     &                    'Element Type= NGON_n, npe =',npe
		    else
			call cg_npe_f(type, npe, ier)
			write(6,112)'Element Type= ',
     &                             ElementTypeName(type)
		    endif
		    write(6,110)(elements(count+n),n=1,npe)
		    count = count+npe
		enddo
	    else
		count = 0
	        do i=1, nelem
		    count = count + 1
		    npe = elements(count)
		    write(6,111) 
     &                    'Element Number Points=',npe
		    write(6,110)(elements(count+n),n=1,npe)
		    count = count+npe
		enddo
	    endif
	enddo

! Write & close CGNS file

	call cg_close_f(cg, ier)
	if (ier .eq. ERROR) call cg_error_exit_f()
	write(6,102)'CGNS File written & closed'

 100	format(a)
 101	format(/a/)
 102	format(/a)
 103	format(6x,2a)
 104 	format(6x,a,i2)
 105	format(6x,a,i2/)
 106	format(6x,a,3i2)
 107	format(6x,a,6i3)
 108	format(6x,a,2i5)
 109	format(8x,a,f8.3)
 110	format(8x,8i3)
 111	format(8x,a,i3)
 112	format(8x,2a)
 113	format(/a,i2,a)
 9999   end
