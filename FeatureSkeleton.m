function [ang_directores_x, ang_directores_y,ang_directores_z, feature_vector, datos, datos_posic, Num] = FeatureSkeleton(datafile)

[datos datos_posic Num]=readSkeletonData(datafile);

% HEAD=datos(i,1,1:14);
% NECK=datos(i,2,1:14);
% TORSO=datos(i,3,1:14);
% LEFT_SHOULDER=datos(i,4,1:14);
% LEFT_ELBOW=datos(i,5,1:14);
% RIGHT_SHOULDER=datos(i,6,1:14);
% RIGHT_ELBOW=datos(i,7,1:14);
% LEFT_HIP=datos(i,8,1:14);
% LEFT_KNEE=datos(i,9,1:14);
% RIGHT_HIP=datos(i,10,1:14);
% RIGHT_KNEE=datos(i,11,1:14);
%
% XN_SKEL_LEFT_HAND=datos_posic(i,1,1:14);
% XN_SKEL_RIGHT_HAND=datos_posic(i,2,1:14);
% XN_SKEL_LEFT_FOOT=datos_posic(i,3,1:14);
% XN_SKEL_RIGHT_FOOT=datos_posic(i,4,1:14);
% 
% see
% http://pr.cs.cornell.edu/humanactivities/data/NITE.pdf
% http://pr.cs.cornell.edu/humanactivities/data.php#format

% angulos directores por c/u de los ejes de orientacion...
% estos si es util? ...identica=[1 0 0;0 1 0;0 0 1];

ang_directores_x = zeros(Num, 11);
ang_directores_y = zeros(Num, 11);
ang_directores_z = zeros(Num, 11);

for i=1:Num
    ang_directores_x(i,1)=acosd(datos(i,1,1));
    ang_directores_y(i,1)=acosd(datos(i,1,5));
    ang_directores_z(i,1)=acosd(datos(i,1,9));
    
    ang_directores_x(i,2)=acosd(datos(i,2,1));
    ang_directores_y(i,2)=acosd(datos(i,2,5));
    ang_directores_z(i,2)=acosd(datos(i,2,9));
    
    ang_directores_x(i,3)=acosd(datos(i,3,1));
    ang_directores_y(i,3)=acosd(datos(i,3,5));
    ang_directores_z(i,3)=acosd(datos(i,3,9));
    
    ang_directores_x(i,4)=acosd(datos(i,4,1));
    ang_directores_y(i,4)=acosd(datos(i,4,5));
    ang_directores_z(i,4)=acosd(datos(i,4,9));
    
    ang_directores_x(i,5)=acosd(datos(i,5,1));
    ang_directores_y(i,5)=acosd(datos(i,5,5));
    ang_directores_z(i,5)=acosd(datos(i,5,9));
    
    ang_directores_x(i,6)=acosd(datos(i,6,1));
    ang_directores_y(i,6)=acosd(datos(i,6,5));
    ang_directores_z(i,6)=acosd(datos(i,6,9));
    
    ang_directores_x(i,7)=acosd(datos(i,7,1));
    ang_directores_y(i,7)=acosd(datos(i,7,5));
    ang_directores_z(i,7)=acosd(datos(i,7,9));
    
    ang_directores_x(i,8)=acosd(datos(i,8,1));
    ang_directores_y(i,8)=acosd(datos(i,8,5));
    ang_directores_z(i,8)=acosd(datos(i,8,9));
    
    ang_directores_x(i,9)=acosd(datos(i,9,1));
    ang_directores_y(i,9)=acosd(datos(i,9,5));
    ang_directores_z(i,9)=acosd(datos(i,9,9));
    
    ang_directores_x(i,10)=acosd(datos(i,10,1));
    ang_directores_y(i,10)=acosd(datos(i,10,5));
    ang_directores_z(i,10)=acosd(datos(i,10,9));
    
    ang_directores_x(i,11)=acosd(datos(i,11,1));
    ang_directores_y(i,11)=acosd(datos(i,11,5));
    ang_directores_z(i,11)=acosd(datos(i,11,9));
end

feature_vector = zeros(Num, 116);
for i=1:Num
    
    % angulos entre partes del cuerpo adyacentes
    
    % angulo entre la cabeza y el torso
    head(1,1:3) = datos(i,1,11:13)-datos(i,2,11:13);
    torso(1,1:3) = datos(i,3,11:13)-datos(i,2,11:13);
    feature_vector(i,1)=acosd(dot(head,torso)/(norm(head)*norm(torso)));
    
    % angulo entre la cabeza y el hombro izquierdo
    left_shoulder(1,1:3) = datos(i,4,11:13)-datos(i,2,11:13);
    feature_vector(i,2) = acosd(dot(head,left_shoulder)/(norm(head)*norm(left_shoulder)));
    
    % angulo ente la cabeza y el hombro derecho
    right_shoulder(1,1:3) = datos(i,6,11:13)-datos(i,2,11:13);
    feature_vector(i,3) = acosd(dot(head,right_shoulder)/(norm(head)*norm(right_shoulder)));
    
    % angulo entre el brazo y el antebrazo izquierdo
    forearm_left(1,1:3) = datos_posic(i,1,1:3)-datos(i,5,11:13);
    arm_left(1,1:3) = datos(i,4,11:13)-datos(i,5,11:13);
    feature_vector(i,4) = acosd(dot(forearm_left,arm_left)/(norm(forearm_left)*norm(arm_left)));
    
    % angulo entre el brazo y el antebrazo derecho
    forearm_right(1,1:3) = datos_posic(i,2,1:3) - datos(i,7,11:13);
    arm_right(1,1:3) = datos(i,6,11:13) - datos(i,7,11:13);
    feature_vector(i,5)=acosd(dot(forearm_right,arm_right)/(norm(forearm_right)*norm(arm_right)));
    
    % angulo entre el brazo y el hombro izquierdo
    left_arm(1,1:3) = datos(i,5,11:13)-datos(i,4,11:13);
    shoulder_left(1,1:3) = datos(i,2,11:13)-datos(i,4,11:13);
    feature_vector(i,6)=acosd(dot(left_arm,shoulder_left)/(norm(left_arm)*norm(shoulder_left)));
    
    % angulo entre el brazo y el hombro derecho
    right_arm(1,1:3) = datos(i,7,11:13)-datos(i,6,11:13);
    shoulder_right(1,1:3) = datos(i,2,11:13)-datos(i,6,11:13);
    feature_vector(i,7)=acosd(dot(right_arm,shoulder_right)/(norm(right_arm)*norm(shoulder_right)));
    
    % angulo entre la pierna y la pantorrila izquierda
    lowerleg_left(1,1:3) = datos_posic(i,3,1:3)-datos(i,9,11:13);
    leg_left(1,1:3) = datos(i,8,11:13)-datos(i,9,11:13);
    feature_vector(i,8)=acosd(dot(lowerleg_left,leg_left)/(norm(lowerleg_left)*norm(leg_left)));
    
    % angulo entre la pierna y la pantorrilla derecha
    lowerleg_right(1,1:3)=datos_posic(i,4,1:3)-datos(i,11,11:13);
    leg_right(1,1:3)=datos(i,10,11:13)-datos(i,11,11:13);
    feature_vector(i,9)=acosd(dot(lowerleg_right,leg_right)/(norm(lowerleg_right)*norm(leg_right)));
    
    % angulo entre la pierna y la cadera izquierda
    left_leg(1,1:3) = datos(i,9,11:13)-datos(i,8,11:13);
    hip_left(1,1:3) = datos(i,3,11:13)-datos(i,8,11:13);
    feature_vector(i,10)=acosd(dot(left_leg,hip_left)/(norm(left_leg)*norm(hip_left)));
    
    % angulo entre la pierna y la cadera derecha
    right_leg(1,1:3) = datos(i,11,11:13)-datos(i,10,11:13);
    hip_right(1,1:3) = datos(i,3,11:13)-datos(i,10,11:13);
    feature_vector(i,11)=acosd(dot(right_leg,hip_right)/(norm(right_leg)*norm(hip_right)));
    
    
    % angulos entre los vectores normales de 5 planos
    % brazos-derecha, brazos-izquierda, piernas-derecha, piernas-izquierda, centro
    
    % angulo entre brazos-izquierda y brazos-derecha
    plane_arm_left=cross(forearm_left,arm_left);
    plane_arm_right=cross(forearm_right,arm_right);
    feature_vector(i,12)=acosd(dot(plane_arm_left,plane_arm_right)/(norm(plane_arm_left)*norm(plane_arm_right)));
    
    % angulo entre brazos-izquierda y centro
    left_hip(1,1:3)=datos(i,8,11:13)-datos(i,3,11:13);
    right_hip(1,1:3)=datos(i,10,11:13)-datos(i,3,11:13);
    plane_center=cross(left_hip,right_hip);
    feature_vector(i,13)=acosd(dot(plane_arm_left,plane_center)/(norm(plane_arm_left)*norm(plane_center)));
    
    % angulo entre brazos-izquierda y piernas-izquierda
    plane_leg_left=cross(lowerleg_left,leg_left);
    feature_vector(i,14)=acosd(dot(plane_arm_left,plane_leg_left)/(norm(plane_arm_left)*norm(plane_leg_left)));
    
    % angulo entre brazos-izquierda y piernas-derecha
    plane_leg_right=cross(lowerleg_right,leg_right);
    feature_vector(i,15)=acosd(dot(plane_arm_left,plane_leg_right)/(norm(plane_arm_left)*norm(plane_leg_right)));
    
    % angulo entre brazos-derecha y centro
    feature_vector(i,16)=acosd(dot(plane_arm_right,plane_center)/(norm(plane_arm_right)*norm(plane_center)));
    
    % angulo entre brazos-derecha y piernas-izquierda
    feature_vector(i,17)=acosd(dot(plane_arm_right,plane_leg_left)/(norm(plane_arm_right)*norm(plane_leg_left)));
    
    % angulo entre brazos-derecha y piernas-derecha
    feature_vector(i,18)=acosd(dot(plane_arm_right,plane_leg_right)/(norm(plane_arm_right)*norm(plane_leg_right)));
    
    % angulo entre centro y piernas-izquierda
    feature_vector(i,19)=acosd(dot(plane_center,plane_leg_left)/(norm(plane_center)*norm(plane_leg_left)));
    
    % angulo entre centro y piernas-derecha
    feature_vector(i,20)=acosd(dot(plane_center,plane_leg_right)/(norm(plane_center)*norm(plane_leg_right)));
    
    % angulo entre piernas-izquierda y piernas-derecha
    feature_vector(i,21)=acosd(dot(plane_leg_left,plane_leg_right)/(norm(plane_leg_left)*norm(plane_leg_right)));
    
    
    % Vectores de cada joint referenciados en el torso como el origen
    vector_head = reshape(datos(i,1,11:13) - datos(i,3,11:13), 1, []);
    vector_neck = reshape(datos(i,2,11:13) - datos(i,3,11:13), 1, []);
    vector_shoulder_left = ...
        reshape(datos(i,4,11:13) - datos(i,3,11:13), 1, []);
    
    vector_elbow_left = reshape(datos(i,5,11:13)-datos(i,3,11:13), 1, []);
    vector_hand_left=reshape(datos_posic(i,1,1:3)-datos(i,3,11:13), 1, []);
    vector_shoulder_right = reshape(datos(i,6,11:13) - datos(i,3,11:13), 1, []);
    vector_elbow_right = reshape(datos(i,7,11:13)-datos(i,3,11:13), 1, []);
    vector_hand_right=reshape(datos_posic(i,2,1:3)-datos(i,3,11:13), 1, []);
    vector_hip_left=reshape(datos(i,8,11:13)-datos(i,3,11:13), 1, []);
    vector_knee_left=reshape(datos(i,9,11:13)-datos(i,3,11:13), 1, []);
    vector_foot_left=reshape(datos_posic(i,3,1:3)-datos(i,3,11:13), 1, []);
    vector_hip_right=reshape(datos(i,10,11:13)-datos(i,3,11:13), 1, []);
    vector_knee_right=reshape(datos(i,11,11:13)-datos(i,3,11:13), 1, []);
    vector_foot_right=reshape(datos_posic(i,4,1:3)-datos(i,3,11:13), 1, []);
    
    % angulos entre los vectores de cada joint entre s�, todos con todos.
    
    % angulo entre lineas cabeza y cuello
    feature_vector(i,22)=acosd(dot(vector_head,vector_neck)/(norm(vector_head)*norm(vector_neck)));
    % angulo entre lineas cabeza y hombro izquierdo
    feature_vector(i,23)=acosd(dot(vector_head,vector_shoulder_left)/(norm(vector_head)*norm(vector_shoulder_left)));
    % angulo entre lineas cabeza y codo izquierdo
    feature_vector(i,24)=acosd(dot(vector_head,vector_elbow_left)/(norm(vector_head)*norm(vector_elbow_left)));
    % angulo entre lineas cabeza y mano izquierda
    feature_vector(i,25)=acosd(dot(vector_head,vector_hand_left)/(norm(vector_head)*norm(vector_hand_left)));
    % angulo entre lineas cabeza y hombro derecho
    feature_vector(i,26)=acosd(dot(vector_head,vector_shoulder_right)/(norm(vector_head)*norm(vector_shoulder_right)));
    % angulo entre lineas cabeza y codo derecho
    feature_vector(i,27)=acosd(dot(vector_head,vector_elbow_right)/(norm(vector_head)*norm(vector_elbow_right)));
    % angulo entre lineas cabeza y mano derecha
    feature_vector(i,28)=acosd(dot(vector_head,vector_hand_right)/(norm(vector_head)*norm(vector_hand_right)));
    % angulo entre lineas cabeza y cadera izquierda
    feature_vector(i,29)=acosd(dot(vector_head,vector_hip_left)/(norm(vector_head)*norm(vector_hip_left)));
    % angulo entre lineas cabeza y rodilla izquierda
    feature_vector(i,30)=acosd(dot(vector_head,vector_knee_left)/(norm(vector_head)*norm(vector_knee_left)));
    % angulo entre lineas cabeza y pie izquierdo
    feature_vector(i,31)=acosd(dot(vector_head,vector_foot_left)/(norm(vector_head)*norm(vector_foot_left)));
    % angulo entre lineas cabeza y cadera derecha
    feature_vector(i,32)=acosd(dot(vector_head,vector_hip_right)/(norm(vector_head)*norm(vector_hip_right)));
    % angulo entre lineas cabeza y rodilla derecha
    feature_vector(i,33)=acosd(dot(vector_head,vector_knee_right)/(norm(vector_head)*norm(vector_knee_right)));
    % angulo entre lineas cabeza y pie derecho
    feature_vector(i,34)=acosd(dot(vector_head,vector_foot_right)/(norm(vector_head)*norm(vector_foot_right)));
    
    
    % angulo entre lineas cuello y hombro izquierdo
    feature_vector(i,35)=acosd(dot(vector_neck,vector_shoulder_left)/(norm(vector_neck)*norm(vector_shoulder_left)));
    % angulo entre lineas cuello y codo izquierdo
    feature_vector(i,36)=acosd(dot(vector_neck,vector_elbow_left)/(norm(vector_neck)*norm(vector_elbow_left)));
    % angulo entre lineas cuello y mano izquierda
    feature_vector(i,37)=acosd(dot(vector_neck,vector_hand_left)/(norm(vector_neck)*norm(vector_hand_left)));
    % angulo entre lineas cuello y hombro derecho
    feature_vector(i,38)=acosd(dot(vector_neck,vector_shoulder_right)/(norm(vector_neck)*norm(vector_shoulder_right)));
    % angulo entre lineas cuello y codo derecho
    feature_vector(i,39)=acosd(dot(vector_neck,vector_elbow_right)/(norm(vector_neck)*norm(vector_elbow_right)));
    % angulo entre lineas cuello y mano derecha
    feature_vector(i,40)=acosd(dot(vector_neck,vector_hand_right)/(norm(vector_neck)*norm(vector_hand_right)));
    % angulo entre lineas cuello y cadera izquierda
    feature_vector(i,41)=acosd(dot(vector_neck,vector_hip_left)/(norm(vector_neck)*norm(vector_hip_left)));
    % angulo entre lineas cuello y rodilla izquierda
    feature_vector(i,42)=acosd(dot(vector_neck,vector_knee_left)/(norm(vector_neck)*norm(vector_knee_left)));
    % angulo entre lineas cuello y pie izquierdo
    feature_vector(i,43)=acosd(dot(vector_neck,vector_foot_left)/(norm(vector_neck)*norm(vector_foot_left)));
    % angulo entre lineas cuello y cadera derecha
    feature_vector(i,44)=acosd(dot(vector_neck,vector_hip_right)/(norm(vector_neck)*norm(vector_hip_right)));
    % angulo entre lineas cuello y rodilla derecha
    feature_vector(i,45)=acosd(dot(vector_neck,vector_knee_right)/(norm(vector_neck)*norm(vector_knee_right)));
    % angulo entre lineas cuello y pie derecho
    feature_vector(i,46)=acosd(dot(vector_neck,vector_foot_right)/(norm(vector_neck)*norm(vector_foot_right)));
    
    % angulo entre lineas hombro izquierdo y codo izquierdo
    feature_vector(i,47)=acosd(dot(vector_shoulder_left,vector_elbow_left)/(norm(vector_shoulder_left)*norm(vector_elbow_left)));
    % angulo entre lineas hombro izquierdo y mano izquierda
    feature_vector(i,48)=acosd(dot(vector_hand_left,vector_shoulder_left)/(norm(vector_hand_left)*norm(vector_shoulder_left)));
    % angulo entre lineas hombro izquierdo y hombro derecho
    feature_vector(i,49)=acosd(dot(vector_shoulder_left,vector_shoulder_right)/(norm(vector_shoulder_left)*norm(vector_shoulder_right)));
    % angulo entre lineas hombro izquierdo y codo derecho
    feature_vector(i,50)=acosd(dot(vector_shoulder_left,vector_elbow_right)/(norm(vector_shoulder_left)*norm(vector_elbow_right)));
    % angulo entre lineas hombro izquierdo y mano derecha
    feature_vector(i,51)=acosd(dot(vector_shoulder_left,vector_hand_right)/(norm(vector_shoulder_left)*norm(vector_hand_right)));
    % angulo entre lineas hombro izquierdo y cadera izquierda
    feature_vector(i,52)=acosd(dot(vector_shoulder_left,vector_hip_left)/(norm(vector_shoulder_left)*norm(vector_hip_left)));
    % angulo entre lineas hombro izquierdo y rodilla izquierda
    feature_vector(i,53)=acosd(dot(vector_shoulder_left,vector_knee_left)/(norm(vector_shoulder_left)*norm(vector_knee_left)));
    % angulo entre lineas hombro izquierdoo y pie izquierdo
    feature_vector(i,54)=acosd(dot(vector_shoulder_left,vector_foot_left)/(norm(vector_shoulder_left)*norm(vector_foot_left)));
    % angulo entre lineas hombro izquierdo y cadera derecha
    feature_vector(i,55)=acosd(dot(vector_shoulder_left,vector_hip_right)/(norm(vector_shoulder_left)*norm(vector_hip_right)));
    % angulo entre lineas hombro izquierdo y rodilla derecha
    feature_vector(i,56)=acosd(dot(vector_shoulder_left,vector_knee_right)/(norm(vector_shoulder_left)*norm(vector_knee_right)));
    % angulo entre lineas hombro izquierdo y pie derecho
    feature_vector(i,57)=acosd(dot(vector_shoulder_left,vector_foot_right)/(norm(vector_shoulder_left)*norm(vector_foot_right)));
    
    
    % angulo entre lineas codo izquierdo y mano izquierda
    feature_vector(i,58)=acosd(dot(vector_elbow_left,vector_hand_left)/(norm(vector_elbow_left)*norm(vector_hand_left)));
    % angulo entre lineas codo izquierdo y hombro derecho
    feature_vector(i,59)=acosd(dot(vector_elbow_left,vector_shoulder_right)/(norm(vector_elbow_left)*norm(vector_shoulder_right)));
    % angulo entre lineas codo izquierdo y codo derecho
    feature_vector(i,60)=acosd(dot(vector_elbow_left,vector_elbow_right)/(norm(vector_elbow_left)*norm(vector_elbow_right)));
    % angulo entre lineas codo izquierdo y mano derecha
    feature_vector(i,61)=acosd(dot(vector_elbow_left,vector_hand_right)/(norm(vector_elbow_left)*norm(vector_hand_right)));
    % angulo entre lineas codo izquierdo y cadera izquierda
    feature_vector(i,62)=acosd(dot(vector_elbow_left,vector_hip_left)/(norm(vector_elbow_left)*norm(vector_hip_left)));
    % angulo entre lineas codo izquierdo y rodilla izquierda
    feature_vector(i,63)=acosd(dot(vector_elbow_left,vector_knee_left)/(norm(vector_elbow_left)*norm(vector_knee_left)));
    % angulo entre lineas codo izquierdo y pie izquierdo
    feature_vector(i,64)=acosd(dot(vector_elbow_left,vector_foot_left)/(norm(vector_elbow_left)*norm(vector_foot_left)));
    % angulo entre lineas codo izquierdo y cadera derecha
    feature_vector(i,65)=acosd(dot(vector_elbow_left,vector_hip_right)/(norm(vector_elbow_left)*norm(vector_hip_right)));
    % angulo entre lineas codo izquierdo y rodilla derecha
    feature_vector(i,66)=acosd(dot(vector_elbow_left,vector_knee_right)/(norm(vector_elbow_left)*norm(vector_knee_right)));
    % angulo entre lineas codo izquierdo y pie derecho
    feature_vector(i,67)=acosd(dot(vector_elbow_left,vector_foot_right)/(norm(vector_elbow_left)*norm(vector_foot_right)));
    
    
    % angulo entre lineas mano izquierda y hombro derecho
    feature_vector(i,68)=acosd(dot(vector_hand_left,vector_shoulder_right)/(norm(vector_hand_left)*norm(vector_shoulder_right)));
    % angulo entre lineas mano izquierda y codo derecho
    feature_vector(i,69)=acosd(dot(vector_hand_left,vector_elbow_right)/(norm(vector_hand_left)*norm(vector_elbow_right)));
    % angulo entre lineas mano izquierda y mano derecha
    feature_vector(i,70)=acosd(dot(vector_hand_left,vector_hand_right)/(norm(vector_hand_left)*norm(vector_hand_right)));
    % angulo entre lineas mano izquierda y cadera izquierda
    feature_vector(i,71)=acosd(dot(vector_hand_left,vector_hip_left)/(norm(vector_hand_left)*norm(vector_hip_left)));
    % angulo entre lineas mano izquierda y rodilla izquierda
    feature_vector(i,72)=acosd(dot(vector_hand_left,vector_knee_left)/(norm(vector_hand_left)*norm(vector_knee_left)));
    % angulo entre lineas mano izquierda y pie izquierdo
    feature_vector(i,73)=acosd(dot(vector_hand_left,vector_foot_left)/(norm(vector_hand_left)*norm(vector_foot_left)));
    % angulo entre lineas mano izquierda y cadera derecha
    feature_vector(i,74)=acosd(dot(vector_hand_left,vector_hip_right)/(norm(vector_hand_left)*norm(vector_hip_right)));
    % angulo entre lineas mano izquierda y rodilla derecha
    feature_vector(i,75)=acosd(dot(vector_hand_left,vector_knee_right)/(norm(vector_hand_left)*norm(vector_knee_right)));
    % angulo entre lineas mano izquierda y pie derecho
    feature_vector(i,76)=acosd(dot(vector_hand_left,vector_foot_right)/(norm(vector_hand_left)*norm(vector_foot_right)));
    
    
    % angulo entre lineas hombro derecho y codo derecho
    feature_vector(i,77)=acosd(dot(vector_shoulder_right,vector_elbow_right)/(norm(vector_shoulder_right)*norm(vector_elbow_right)));
    % angulo entre lineas hombro derecho y mano derecha
    feature_vector(i,78)=acosd(dot(vector_hand_right,vector_shoulder_right)/(norm(vector_hand_right)*norm(vector_shoulder_right)));
    % angulo entre lineas hombro derecho y cadera izquierda
    feature_vector(i,79)=acosd(dot(vector_shoulder_right,vector_hip_left)/(norm(vector_shoulder_right)*norm(vector_hip_left)));
    % angulo entre lineas hombro derecho y rodilla izquierda
    feature_vector(i,80)=acosd(dot(vector_shoulder_right,vector_knee_left)/(norm(vector_shoulder_right)*norm(vector_knee_left)));
    % angulo entre lineas hombro derecho y pie izquierdo
    feature_vector(i,81)=acosd(dot(vector_shoulder_right,vector_foot_left)/(norm(vector_shoulder_right)*norm(vector_foot_left)));
    % angulo entre lineas hombro derecho y cadera derecha
    feature_vector(i,82)=acosd(dot(vector_shoulder_right,vector_hip_right)/(norm(vector_shoulder_right)*norm(vector_hip_right)));
    % angulo entre lineas hombro derecho y rodilla derecha
    feature_vector(i,83)=acosd(dot(vector_shoulder_right,vector_knee_right)/(norm(vector_shoulder_right)*norm(vector_knee_right)));
    % angulo entre lineas hombro derecho y pie derecho
    feature_vector(i,84)=acosd(dot(vector_shoulder_right,vector_foot_right)/(norm(vector_shoulder_right)*norm(vector_foot_right)));
    
    
    % angulo entre lineas codo derecho y mano derecha
    feature_vector(i,85)=acosd(dot(vector_elbow_right,vector_hand_right)/(norm(vector_elbow_right)*norm(vector_hand_right)));
    % angulo entre lineas codo derecho y cadera izquierda
    feature_vector(i,86)=acosd(dot(vector_elbow_right,vector_hip_left)/(norm(vector_elbow_right)*norm(vector_hip_left)));
    % angulo entre lineas codo derecho y rodilla izquierda
    feature_vector(i,87)=acosd(dot(vector_elbow_right,vector_knee_left)/(norm(vector_elbow_right)*norm(vector_knee_left)));
    % angulo entre lineas codo derecho y pie izquierdo
    feature_vector(i,88)=acosd(dot(vector_elbow_right,vector_foot_left)/(norm(vector_elbow_right)*norm(vector_foot_left)));
    % angulo entre lineas codo derecho y cadera derecha
    feature_vector(i,89)=acosd(dot(vector_elbow_right,vector_hip_right)/(norm(vector_elbow_right)*norm(vector_hip_right)));
    % angulo entre lineas codo derecho y rodilla derecha
    feature_vector(i,90)=acosd(dot(vector_elbow_right,vector_knee_right)/(norm(vector_elbow_right)*norm(vector_knee_right)));
    % angulo entre lineas codo derecho y pie derecho
    feature_vector(i,91)=acosd(dot(vector_elbow_right,vector_foot_right)/(norm(vector_elbow_right)*norm(vector_foot_right)));
    
    
    % angulo entre lineas mano derecha y cadera izquierda
    feature_vector(i,92)=acosd(dot(vector_hand_right,vector_hip_left)/(norm(vector_hand_right)*norm(vector_hip_left)));
    % angulo entre lineas mano derecha y rodilla izquierda
    feature_vector(i,93)=acosd(dot(vector_hand_right,vector_knee_left)/(norm(vector_hand_right)*norm(vector_knee_left)));
    % angulo entre lineas mano derecha y pie izquierdo
    feature_vector(i,94)=acosd(dot(vector_hand_right,vector_foot_left)/(norm(vector_hand_right)*norm(vector_foot_left)));
    % angulo entre lineas mano derecha y cadera derecha
    feature_vector(i,95)=acosd(dot(vector_hand_right,vector_hip_right)/(norm(vector_hand_right)*norm(vector_hip_right)));
    % angulo entre lineas mano derecha y rodilla derecha
    feature_vector(i,96)=acosd(dot(vector_hand_right,vector_knee_left)/(norm(vector_hand_right)*norm(vector_knee_left)));
    % angulo entre lineas mano derecha y pie derecho
    feature_vector(i,97)=acosd(dot(vector_hand_right,vector_foot_right)/(norm(vector_hand_right)*norm(vector_foot_right)));
    
    
    % angulo entre lineas cadera izquierda y rodilla izquierda
    feature_vector(i,98)=acosd(dot(vector_hip_left,vector_knee_left)/(norm(vector_hip_left)*norm(vector_knee_left)));
    % angulo entre lineas cadera izquierda y pie izquierdo
    feature_vector(i,99)=acosd(dot(vector_foot_left,vector_hip_left)/(norm(vector_foot_left)*norm(vector_hip_left)));
    % angulo entre lineas cadera izquierda y cadera derecha
    feature_vector(i,100)=acosd(dot(vector_hip_left,vector_hip_right)/(norm(vector_hip_left)*norm(vector_hip_right)));
    % angulo entre lineas cadera izquierda y rodilla derecha
    feature_vector(i,101)=acosd(dot(vector_hip_left,vector_knee_right)/(norm(vector_hip_left)*norm(vector_knee_right)));
    % angulo entre lineas cadera izquierda y pie derecho
    feature_vector(i,102)=acosd(dot(vector_hip_left,vector_foot_right)/(norm(vector_hip_left)*norm(vector_foot_right)));
    
    
    % angulo entre lineas rodilla izquierda y pie izquierdo
    feature_vector(i,103)=acosd(dot(vector_knee_left,vector_foot_left)/(norm(vector_knee_left)*norm(vector_foot_left)));
    % angulo entre lineas rodilla izquierda y cadera derecha
    feature_vector(i,104)=acosd(dot(vector_knee_left,vector_hip_right)/(norm(vector_knee_left)*norm(vector_hip_right)));
    % angulo entre lineas rodilla izquierda y rodilla derecha
    feature_vector(i,105)=acosd(dot(vector_knee_left,vector_knee_right)/(norm(vector_knee_left)*norm(vector_knee_right)));
    % angulo entre lineas rodilla izquierda y pie derecho
    feature_vector(i,106)=acosd(dot(vector_knee_left,vector_foot_right)/(norm(vector_knee_left)*norm(vector_foot_right)));
    
    % angulo entre lineas pie izquierdo y cadera derecha
    feature_vector(i,107)=acosd(dot(vector_foot_left,vector_hip_right)/(norm(vector_foot_left)*norm(vector_hip_right)));
    % angulo entre lineas pie izquierdo y rodilla derecha
    feature_vector(i,108)=acosd(dot(vector_foot_left,vector_knee_right)/(norm(vector_foot_left)*norm(vector_knee_right)));
    % angulo entre lineas pie izquierdo y pie derecho
    feature_vector(i,109)=acosd(dot(vector_foot_left,vector_foot_right)/(norm(vector_foot_left)*norm(vector_foot_right)));
    
    % angulo entre lineas cadera derecha y rodilla derecha
    feature_vector(i,110)=acosd(dot(vector_hip_right,vector_knee_right)/(norm(vector_hip_right)*norm(vector_knee_right)));
    % angulo entre lineas cadera derecha y pie derecho
    feature_vector(i,111)=acosd(dot(vector_foot_right,vector_hip_right)/(norm(vector_foot_right)*norm(vector_hip_right)));
    
    % angulo entre lineas rodilla derecha y pie derecho
    feature_vector(i,112)=acosd(dot(vector_knee_right,vector_foot_right)/(norm(vector_knee_right)*norm(vector_foot_right)));
    
    % angulos adicionales
    
    % angulo entre el vector hombro-cadera y el brazo izquierdo
    hip_shoulder_left(1,1:3) = datos(i,8,11:13)-datos(i,4,11:13);
    feature_vector(i,113)=acosd(dot(left_arm,hip_shoulder_left)/(norm(left_arm)*norm(hip_shoulder_left)));
    
    % angulo entre el vector hombro-cadera y el brazo derecho
    hip_shoulder_right(1,1:3) = datos(i,10,11:13)-datos(i,6,11:13);
    feature_vector(i,114)=acosd(dot(right_arm,hip_shoulder_right)/(norm(right_arm)*norm(hip_shoulder_right)));
    
    % angulo entre el vector de las dos uniones de la cadera y la pierna izquierda
    hip_left_right(1,1:3) = datos(i,10,11:13)-datos(i,8,11:13);
    feature_vector(i,115)=acosd(dot(left_leg,hip_left_right)/(norm(left_leg)*norm(hip_left_right)));
    
    % angulo entre el vector de los joints de la cadera y la pierna derecha
    hip_right_left(1,1:3) = datos(i,8,11:13)-datos(i,10,11:13);
    feature_vector(i,116)=acosd(dot(right_leg,hip_right_left)/(norm(right_leg)*norm(hip_right_left)));
    
end
