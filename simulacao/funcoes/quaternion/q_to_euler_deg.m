function eul = q_to_euler_deg(q)
%Q_TO_EULER_DEG Euler [roll pitch yaw] em graus, convenção ZYX.
%   Só para visualização, como qToEulerDeg() do firmware.
r2d = 180 / pi;
w = q(:,1); x = q(:,2); y = q(:,3); z = q(:,4);
roll = atan2(2*(w.*x + y.*z), 1 - 2*(x.^2 + y.^2)) * r2d;
s = max(min(2*(w.*y - z.*x), 1), -1);
pitch = asin(s) * r2d;
yaw = atan2(2*(w.*z + x.*y), 1 - 2*(y.^2 + z.^2)) * r2d;
eul = [roll, pitch, yaw];
end
