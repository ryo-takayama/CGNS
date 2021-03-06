/*   Program read_flowvert_str   */
/*
Opens an existing CGNS file that contains a simple 3-D 
structured grid plus a flow solution (at VERTICES),
and reads it.

The CGNS grid file 'grid_c.cgns' must already exist
(created using write_grid_str.c followed by
write_flowvert_str.c)

Example compilation for this program is (change paths!):

cc -I ../CGNS_CVS/cgnslib_2.5 -c read_flowvert_str.c
cc -o read_flowvert_str_c read_flowvert_str.o -L ../CGNS_CVS/cgnslib_2.5/LINUX -lcgns

(../CGNS_CVS/cgnslib_2.5/LINUX/ is the location where the compiled
library libcgns.a is located)
*/

#include <stdio.h>
/* cgnslib.h file must be located in directory specified by -I during compile: */
#include "cgnslib.h"

#if CGNS_VERSION < 3100
# define cgsize_t int
#else
# if CG_BUILD_SCOPE
#  error enumeration scoping needs to be off
# endif
#endif

int main()
{
/*
  dimension statements (note that tri-dimensional arrays
  r and p must be dimensioned exactly as [N][17][21] (N>=9) 
  for this particular case or else they will be read from 
  the CGNS file incorrectly!  Other options are to use 1-D 
  arrays, use dynamic memory, or pass index values to a 
  subroutine and dimension exactly there):
*/
    float r[9][17][21],p[9][17][21];
    cgsize_t isize[3][3],irmin[3],irmax[3];
    int index_file,index_base,index_zone,index_flow;
    char zonename[33],solname[33];
    GridLocation_t loc;

/* READ FLOW SOLUTION FROM CGNS FILE */
/* open CGNS file for read-only */
    if (cg_open("grid_c.cgns",CG_MODE_READ,&index_file)) cg_error_exit();
/* we know there is only one base (real working code would check!) */
    index_base=1;
/* we know there is only one zone (real working code would check!) */
    index_zone=1;
/* we know there is only one FlowSolution_t (real working code would check!) */
    index_flow=1;
/* get zone size (and name - although not needed here) */
    cg_zone_read(index_file,index_base,index_zone,zonename,isize[0]);
/* lower range index */
    irmin[0]=1;
    irmin[1]=1;
    irmin[2]=1;
/* upper range index - use vertex dimensions */
/* checking GridLocation first (real working code would check */
/* to make sure there are no Rind cells also!): */
    cg_sol_info(index_file,index_base,index_zone,index_flow,solname,&loc);
    if (loc != Vertex)
    {
      printf("\nError, GridLocation must be Vertex! Currently: %s\n",
          GridLocationName[loc]);
      return 1;
    }
    irmax[0]=isize[0][0];
    irmax[1]=isize[0][1];
    irmax[2]=isize[0][2];
/* read flow solution */
    cg_field_read(index_file,index_base,index_zone,index_flow,"Density",
                  RealSingle,irmin,irmax,r[0][0]);
    cg_field_read(index_file,index_base,index_zone,index_flow,"Pressure",
                  RealSingle,irmin,irmax,p[0][0]);
/* close CGNS file */
    cg_close(index_file);
    printf("\nSuccessfully read flow solution from file grid_c.cgns\n");
    printf("  For example, r,p[8][16][20]= %f, %f\n",r[8][16][20],p[8][16][20]);
    printf("\nProgram successful... ending now\n");
    return 0;
}
