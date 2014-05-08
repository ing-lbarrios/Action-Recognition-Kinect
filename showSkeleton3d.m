function showSkeleton3d(data, data_pos, figure_number, figure_title)

% actual visualization

if ~exist('figure_title','var')
    figure_title = '';
end

if ~exist('figure_number','var') || isempty(figure_number)
    figure(1);
else
    figure(figure_number);
end

clf;hold on
lineLen=30;
linewidth=2;

if ~exist('data_pos','var') || isempty(data_pos) 
    new_data = zeros(11, 14);
    new_data(:, 11:13) = data(1:11,:);
    data_pos = zeros(4, 4);
    data_pos(:,1:3) = data(12:15,:);
    old_data = data;
    data = new_data;
end

for i=1:11,
    xyz = data(i,[11,12,13]);
    x=xyz(1);
    y=xyz(2);
    z=xyz(3);
    plot3(x,y,z,'r.', 'MarkerSize',15);
    
    vect = data(i,[1,4,7])*lineLen;
    vect = xyz+vect;
    xd = vect(1);
    yd = vect(2);
    zd = vect(3);
    line([x,xd],[y,yd],[z,zd],'Color','r', 'LineWidth',linewidth);
    
    vect = data(i,[2,5,8])*lineLen;
    vect = xyz+vect;
    xd = vect(1);
    yd = vect(2);
    zd = vect(3);
    line([x,xd],[y,yd],[z,zd],'Color','g', 'LineWidth',linewidth);
    
    vect = data(i,[3,6,9])*lineLen;
    vect = xyz+vect;
    xd = vect(1);
    yd = vect(2);
    zd = vect(3);
    line([x,xd],[y,yd],[z,zd],'Color','b', 'LineWidth',linewidth);
end

for i=1:4,
    xyz = data_pos(i,[1,2,3]);
    x=xyz(1);
    y=xyz(2);
    z=xyz(3);
    plot3(x,y,z,'B.','MarkerSize',15);
end

% show body segments
plotBodyPart(data(1,11:13), data(2,11:13))
plotBodyPart(data(2,11:13), data(3,11:13))
plotBodyPart(data(2,11:13), data(4,11:13))
plotBodyPart(data(2,11:13), data(6,11:13))
plotBodyPart(data(4,11:13), data(5,11:13))
plotBodyPart(data(6,11:13), data(7,11:13))
plotBodyPart(data(3,11:13), data(8,11:13))
plotBodyPart(data(3,11:13), data(10,11:13))
plotBodyPart(data(8,11:13), data(9,11:13))
plotBodyPart(data(10,11:13), data(11,11:13))

plotBodyPart(data(5,11:13), data_pos(1,1:3))
plotBodyPart(data(7,11:13), data_pos(2,1:3))
plotBodyPart(data(9,11:13), data_pos(3,1:3))
plotBodyPart(data_pos(4,1:3), data(11,11:13))

xlabel('x')
ylabel('y')
zlabel('z')
title(figure_title);
hold off
shading interp
colormap bone
axis equal

set(gca,'xlim',[-2.000 2.000]);
set(gca,'ylim',[-1.200 1.000]);

% set(gca,'xlim',[-2000 2000]);
% set(gca,'ylim',[-1200 1000]);

end


function plotBodyPart(first_joint, second_joint)

part_vector = first_joint - second_joint;
normalized_part_vector = part_vector ./ norm(part_vector);
translation_vector = mean([first_joint; second_joint]);

% Rotation matrix, according to post# 2 in:
% http://www.physicsforums.com/showthread.php?t=432279
w_long = cross([1 0 0], normalized_part_vector);
w = w_long ./ norm(w_long);
U = [ [1; 0; 0], w', cross([1 0 0], w_long)'];
V = [ normalized_part_vector', w', cross(normalized_part_vector, w_long)'];
R = V*U';

% TODO: there is a bug: sometimes the determinant is close to 0, instead of
% close to 1. This causes the ellipsoid to collapse into a flat ellipse.
% One of the causes may be that the target is (almost) parallel to an axis.
% det(U)
% det(V)
% if det(U)<0.2
%     keyboard
% end
rotation_matrix(1:3, 1:3) = R;
rotation_matrix(1:3,4) = translation_vector;
rotation_matrix(4,4) = 1;

[ex,ey,ez] = ellipsoid(0,0,0,norm(part_vector)/2, 0.05, 0.05);
%[ex,ey,ez] = ellipsoid(0,0,0,norm(part_vector)/2, 30, 30);

aa = cat(3, ex, ey, ez);
bb = permute(aa, [3 1 2]);
cc = reshape(bb, 3, []);
dd = [cc; ones(1,size(cc,2))];

new_dd = rotation_matrix*dd;

new_cc = new_dd(1:3,:);
new_bb = reshape(new_cc,3,size(bb,2),size(bb,3));
new_aa = permute(new_bb, [2 3 1]);
new_ex = new_aa(:,:,1);
new_ey = new_aa(:,:,2);
new_ez = new_aa(:,:,3);

surfl(new_ex, new_ey, new_ez)

end
