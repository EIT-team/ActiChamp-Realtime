%Mesh is the SA060 cylindrical tank mesh: tri, vtx, mat_ref, pos
%We only really need a 2D slice across the z-plane, as the electrodes are
%in a 2D arrangemnt, so centre_inds returns the indicies of the points
%which are within +/- z_axis_size of z plane.
function [mesh_simple centre_inds] = hex_mesh_simplify(Mesh, z_axis_size)

for i = 1:size(Mesh.Hex,1)
    
    mesh_simple(1,i) = sum(Mesh.Nodes(Mesh.Hex(i,:),1))/8;
    mesh_simple(2,i) = sum(Mesh.Nodes(Mesh.Hex(i,:),2))/8;
    mesh_simple(3,i) = sum(Mesh.Nodes(Mesh.Hex(i,:),3))/8;
    
end
%
centre_inds = abs(mesh_simple(3,:)) < z_axis_size;
end