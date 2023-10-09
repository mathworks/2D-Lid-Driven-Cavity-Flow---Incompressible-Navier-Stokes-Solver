function dp = solvePoissonEquation_direct_channel(b,nx,ny,dx,dy)
% Copyright 2023 The MathWorks, Inc.

persistent Abig sizeAbig

% So that you do not have to calculate Abig everytime
if isempty(Abig) || any(sizeAbig ~= [nx*ny,nx*ny])
    
    % �s�� A �̍\�z�i�������ߖ�̂��߃X�p�[�X�s��Œ�`�j
    % �܂� x �����̔����Ɋւ��镔���i�O�d�Ίp�s��j�����`���܂��B
    tmp = -2*ones(nx,1);
    % tmp([1,end]) = -1; % Neumann ���E�������l�������[�� -1 (not -2)
    % Periodic ���E�����͂��ׂ� -2
    Ad = diag(tmp);
    Au = diag(ones(nx-1,1),1);
    Al = diag(ones(nx-1,1),-1);
    Ax = Ad+Au+Al;
    % for periodic case
    Ax(end,1) = 1;
    Ax(1,end) = 1;
    
    % ��Ɠ����s����������������ɏ����Ƃ�����B
    % �܂��u���b�N�Ίp�s�񐬕����쐬
    dd = eye(nx);
    tmp = repmat({sparse(Ax/dx^2 - 2*dd/dy^2)},ny,1);
    tmp{1} = Ax/dx^2 - dd/dy^2;
    tmp{ny} = Ax/dx^2 - dd/dy^2; % y-�����̒[�͒��ӁiNeumann BC)
    Abig = blkdiag(tmp{:});
    
    % 1�u���b�N���������Ίp�s��� y�����������쐬
    d4y = eye(nx*(ny-1),'like',sparse(1));
    Abig(1:end-nx,nx+1:end) = Abig(1:end-nx,nx+1:end) + d4y/dy^2; % �㑤
    Abig(nx+1:end,1:end-nx) = Abig(nx+1:end,1:end-nx) + d4y/dy^2; % ����
    %Velocity and pressure correction using phi

    % Abig �͓��ٍs��ł��肱�̂܂܂ł͉�����ӂɒ�܂�Ȃ��̂ŁA
    % 1�_�� u = 0 �ƌŒ肵�ĉ��Ƃ��܂��B
    Abig(1,:) = 0;
    Abig(1,1) = 1;
    
    sizeAbig = size(Abig);
    % Pre-decompose the matrix for fater inversion
    Abig = decomposition(Abig);
end

% �E��
f = b(:); % �x�N�g����

% Abig �͓��ٍs��ł��肱�̂܂܂ł͉�����ӂɒ�܂�Ȃ��̂ŁA
% 1�_�� u = 0 �ƌŒ肵�ĉ��Ƃ��܂��B
f(1) = 0;

% ����
dp = Abig\f;

% 2�����z��ɖ߂��Ă����܂��B
dp = reshape(dp,[nx,ny]);

% adding periodic value
dp = [dp;dp(1,:)];

end