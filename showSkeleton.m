function showSkeleton(data, data_pos, figure_number, figure_title)

% actual visualization

if ~exist('figure_title','var')
    figure_title = '';
end

if ~exist('figure_number','var')
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
line([data(1,11),data(2,11)],[data(1,12),data(2,12)],[data(1,13),data(2,13)],'Color','m', 'LineWidth',linewidth);
line([data(2,11),data(3,11)],[data(2,12),data(3,12)],[data(2,13),data(3,13)],'Color','m', 'LineWidth',linewidth);
line([data(2,11),data(4,11)],[data(2,12),data(4,12)],[data(2,13),data(4,13)],'Color','m', 'LineWidth',linewidth);
line([data(2,11),data(6,11)],[data(2,12),data(6,12)],[data(2,13),data(6,13)],'Color','m', 'LineWidth',linewidth);
line([data(4,11),data(5,11)],[data(4,12),data(5,12)],[data(4,13),data(5,13)],'Color','m', 'LineWidth',linewidth);
line([data(6,11),data(7,11)],[data(6,12),data(7,12)],[data(6,13),data(7,13)],'Color','m', 'LineWidth',linewidth);
line([data(3,11),data(8,11)],[data(3,12),data(8,12)],[data(3,13),data(8,13)],'Color','m', 'LineWidth',linewidth);
line([data(3,11),data(10,11)],[data(3,12),data(10,12)],[data(3,13),data(10,13)],'Color','m', 'LineWidth',linewidth);
line([data(8,11),data(9,11)],[data(8,12),data(9,12)],[data(8,13),data(9,13)],'Color','m', 'LineWidth',linewidth);
line([data(10,11),data(11,11)],[data(10,12),data(11,12)],[data(10,13),data(11,13)],'Color','m', 'LineWidth',linewidth);


line([data(5,11),data_pos(1,1)],[data(5,12),data_pos(1,2)],[data(5,13),data_pos(1,3)],'Color','m', 'LineWidth',linewidth);
line([data(7,11),data_pos(2,1)],[data(7,12),data_pos(2,2)],[data(7,13),data_pos(2,3)],'Color','m', 'LineWidth',linewidth);
line([data(9,11),data_pos(3,1)],[data(9,12),data_pos(3,2)],[data(9,13),data_pos(3,3)],'Color','m', 'LineWidth',linewidth);
line([data(11,11),data_pos(4,1)],[data(11,12),data_pos(4,2)],[data(11,13),data_pos(4,3)],'Color','m', 'LineWidth',linewidth);

% 
%  plotBodyPart(data(1,11:13), data(2,11:13))
%  plotBodyPart(data(2,11:13), data(3,11:13))
%  plotBodyPart(data(2,11:13), data(4,11:13))
%  plotBodyPart(data(2,11:13), data(6,11:13))
%  plotBodyPart(data(4,11:13), data(5,11:13))
% plotBodyPart(data(6,11:13), data(7,11:13))
% plotBodyPart(data(3,11:13), data(8,11:13))
% plotBodyPart(data(3,11:13), data(10,11:13))
% plotBodyPart(data(8,11:13), data(9,11:13))
% plotBodyPart(data(10,11:13), data(11,11:13))
%
% plotBodyPart(data(5,11:13), data_pos(1,1:3))
% plotBodyPart(data(7,11:13), data_pos(2,1:3))
% plotBodyPart(data(9,11:13), data_pos(3,1:3))
% plotBodyPart(data_pos(4,1:3), data(11,11:13))


%line([data(6,11),data(10,11)],[data(6,12),data(10,12)],[data(6,13),data(10,13)],'Color','m', 'LineWidth',linewidth);

line(data([6 10],11), data([6 10],12), data([6 10],13),'Color','m', 'LineWidth',linewidth);
line(data([8 10],11), data([8 10],12), data([8 10],13),'Color','m', 'LineWidth',linewidth);
line(data([4 8],11), data([4 8],12), data([4 8],13),'Color','m', 'LineWidth',linewidth);

xlabel('x')
ylabel('y')
zlabel('z')
title(figure_title);
legend('joints','x','y','z');
hold off
set(gca,'xlim',[-1000 1000]);
set(gca,'ylim',[-1200 1000]);
% axis([-1000 1000 -1000 -1000 -10 10])
shading interp
colormap bone
axis equal

end


function plotBodyPart(first_joint, second_joint)

part_vector = first_joint - second_joint;
angles_vector = acos(part_vector ./ norm(part_vector));

% alpha = 0;beta=0;gamma=0;
alpha = angles_vector(1);
beta = angles_vector(2);
gamma = angles_vector(3);

% Here we construct a rotation matrix, based on the angles to the x, y, z
% axis (See http://planning.cs.uiuc.edu/node104.html)

rotation_matrix = zeros(4,4);
rotation_matrix(1,1) = cos(alpha)*cos(beta);
rotation_matrix(2,1) = sin(alpha)*cos(beta);
rotation_matrix(3,1) = -sin(beta);

rotation_matrix(1,2) = cos(alpha)*sin(beta)*sin(gamma) - sin(alpha)*cos(gamma);
rotation_matrix(2,2) = sin(alpha)*sin(beta)*sin(gamma) + cos(alpha)*cos(gamma);
rotation_matrix(3,2) = cos(beta)*sin(gamma);

rotation_matrix(1,3) = cos(alpha)*sin(beta)*cos(gamma) + sin(alpha)*sin(gamma);
rotation_matrix(2,3) = sin(alpha)*sin(beta)*cos(gamma) - cos(alpha)*sin(gamma);
rotation_matrix(3,3) = cos(beta)*cos(gamma);

rotation_matrix(1,4) = mean([first_joint(1), second_joint(1)]);
rotation_matrix(2,4) = mean([first_joint(2), second_joint(2)]);
rotation_matrix(3,4) = mean([first_joint(3), second_joint(3)]);
rotation_matrix(4,4) = 1;

[ex,ey,ez] = ellipsoid(0,0,0,norm(part_vector)/2,30,30);

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
%surfl(ex, ey, ez)
%shading interp

end
