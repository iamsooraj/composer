ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.11.3
docker tag hyperledger/composer-playground:0.11.3 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� �Y �=�r۸����sfy*{N���aj0Lj�LFI��匧��(Y�.�n����P$ѢH/�����W��>������V� %S[�/Jf����4���h4@�P��
)F�4l25yضWo��=��� � ���h�c�1p�?a�,eY�P:����<P���k;��ǒ��}3ޢ��(��e�����m����Wh�R >OX��7���Ȫ�3]���q.�T{r�u�&�4�lC+2��A5˱�*��f�����&iP𥳐���R��a�"��R�b&��?� |��n�jN��u�8�S���R5H����䆥*���4��p�u�@����G���}�l�RM�Fܿ �!E@�3������gg��pX���cX+�1zp<��x�6�H��f�iC�A�uPQ���5�&�s��wSy`f$H	��01m�Tv#�|^�=S����8#0�Lѫ��3�(M�}ԵQ�n�6si�Y��l�r8���s����㘈~E��i����|0��tw�f�1�J�l�_]h;�r>0ظf.���Cj�}���]bΨ�r�&%.��+��!�Nl�T"F�R�V�ҳS+�0�s@�Lu�K�����D+�J��=��.k#M4���|\�S����7�&쇰�G�y�6�"�7����4ơ���f ��9����s�߁��4��@���}� �/�<�,���g�1^�x��<����Ͼ�4T=Ґ�e��@@?�&��T-����I��V)��)���/i����4ѯșf�h�G��ֆ_̑,�x:?��s����6��e��7e�����s������o���H;`���R������������u�����D�	3a�K��m@̈́��48�#�y>&��$��2,���C�0��ٟ�L�,� �R���it,�$�u:�5�T�5U��Mz$"f���et�m��׻m:�JW��h��m&銡��K6�;~�;jBm[u� "�Z����N�n���ɖ�Q��n��	B!�;�@��N@F��B#��mx5���'£�<I�/U/��c/������IL�ʠa⍹��6J�K�[�����ׁ����?���gc1�shM6����g [y����)��쀮�iDY[�g�!J��ru]���lj\�v��K�#E�{�_4	��__Rj����!�,��� M��q�:RDP��>@��e��l;4 �s?�b؈�jv�y-:I�TKE�s����ֹ[/�N��_�Y�H� ���^�Q̌���Jb������B���h���q[L�W�6�ULq�`��Z�q�=��cb^�Α��[�1��|��Kگ�!p0�A��ɀ��G��Obs0�8w�c��Q��ꢨ�#WuH!L{�@?�N��CV�{��ejPq���*`��h��i� �	�d�!�:9�i����+�@�����m�^#"�/j���g쌞n�%�� 4,(w_��F�jy������4�/T�O���PMC����K�9�?f���`X���� ~���6��/����\>P��������z�������:�<�5�,=m����eh4��ݬ%7<#͵,\���1�!�Ε��N��~�rVI�s�ս�!��b�7߲+�;����Wۘ$b,�.�����\�.�+�R���յ���@���������x8�G.��{~�5�\'�o��Of!b�Ne��JU,WϪ��T�Uo�zm�� ^�MV�~9Ӆ��{���ۅ����;&����9��B~޽��6��w�܂��0ޒ��FRwA��2��^Z4��{�51K���1Y����@��1b�+:�8�Y����Г\D9�������G;9?2�>�����2�o=����l����-�!7���?�2��_\�n����O=����L7{@�фh�L��0Z�Q�c��}�u�s��^���ƙXt��X<�x�Äc���E�ߟ����p���u������E���?\T6������_	����-�в�G`Z���D{=Yo�a
��C���'|g���q�e��=�U��p�=��8j�՜8�B-���|���b��\�&Sw�L�QӪtc �:������v�?Lo=&{�������e�@�j���r��B~Uv�?����0�����03�����Â�?3+��M��Z�s����1�����ٓXM&�s�#�0�`���c���`T�P��N�,Ƈ�0fF�pSK�ӣ��۟��������s�M��z�Q����R�yt�
X����$�R��\����#����(���u��g~�>	؇�k�[���o��w	����?.�������n�-�����9�\yy|��zD%��"���I��?��R��*��(����	\�2:�Ӄ8���fſjg��Pd�c�N�rE�-x�CA�V�}�qnt�;u������tu��1� �f�eթ�މ�(3>\��}���,ʤ�+
��(�<����h�`�u��c����V�+���xhX��3mn/�����c´�'��7��+$���Kn����s�55q�WlcME�նwi�!sn��ER!)�+�z�,%���?�(&�Rz�����da�8� ��5�Ha���p8��D��ܞGp�Je��P��gb:]�*�V-�����r�h��I���+V�\]�@Z8җ�����m�'X$_�fs��Y^�K�����egΥ�Ј�$��$4x�������I��]];_Y�"�j�\�dbo@(��y��:����gY��'f�R>w�Fak��O�����mB�f�M�KƳ�74���̛��y��ZhV���5,h����M�&��������n�<~� �S�5o�W�n�j	5A(DN��5 ������[�Ԡ�M�����~��G����X�[�7�ޭ{1_��b/'�콢���� ����o"����Ǉe��>��-��0,75�Ѩ�n��:�s��{��Ґ:��xvQX�+�-a �#�D/����Գ%�`D�<��/�!rU���؉[B�t��X��kn\�Ԝ��O����\
���g�c�/p1O�o���>_��8�9�0
�a�X�
(�j�
��+��/J_��U:��d�;�����K!�����6��z���/6�-U=��q@cL�6]��M8��%D-+��9�@�9�ٟ���qn����+��r�òQk.<`�C`Xm@�� �|�zg����Gp]�R�9#�o,��Q�r��_��,�����G��pC�C�Ol������L��2� &_Y���U Bb����E�>�27�b\d�)S��7D�]�Kh��'nnz�&������-:��o�-~���?�pwhcu�?g������_+1O=���Em,���i�O���_���|M�Q����?|���_������֟~����<��i)���	��h��N"k5��eȳ���F"�+2�	���Ǝ l��W��~EMW����7�O�ij*�_�!��t�O���m�ɷ�)*e�a9����׭��F��u�������d5�o�������y;�����?�[��������R��[�z�2�i�����0��~�kX��O=�7���O,ܕ�X]�G���_�q����-������?/�7�-���cX�o5�&J�4h� ���0�i�����=�A�\��|KV �g:���H�j{�rd��
���``<�h1J|'��v����%�sQe��NSf������D���rB���&�qmi"U��k �NCR�� %���L.%V%��^/�r��y*%*��8�%�v�,ݒ^/�6#���xW��R�܁q��<g$�;P.�<�A�fE�&%;�T�^��.�r�]�����n���j�F�+K�s���)�t���{]�e�N�<�v.�U�aT�lbxz)��o;��ۤ}Z�s��e�P��b罞����w�b����9�P�1�j�;�i�$���׏ϓ�=H���GGYi�^���4p�w�d�������i_�	�IU:.$���_����qs����X8����R��d�8��X�X腊��l�Q�Z�W�7��S4��B69�5[)�	�-eS)��@����̺;�#6۽�Tu#ߏߪ'��K�q8.W�$��|���ʵ։| d�fEU�B�4~j�;�J<g����)/����y���D����H�����~;-�X�I��#��XHٸW���[H��d�:��x2�L�׭r�;8��j����R�bR�XA�����݂h�{�f0%2m� �R��o���)��k�z��2!'"��U<�`E?��~�i��� f�o�M#cH�,��Dܭ������2�S|"�okeq�NX^*��}uu��#����W�Ǌk���O�eX�n��-��l��=�G�gF��2�6�E��Q���_��/:}�o`M�`�����/�ۜ�\��r��p ��ԧT!��Gk�x���2�PGGm����䁡Fj�{J���:Sa��b�X��Z&�����ιdr�D�l�S�Q�X6��eFN�_]��^J3^5`�)�׻��QY

��>�U۩α^3�Z� '+b$]s���~��=�,t�B�)5^�f;��G���c��g�a���>���6>u�7���X��9�?�9�����d>�
.���@���x4v���#%}�%9>��L�&W3o
�m7b��M۔{ѧ�Qʜf
]	*n���[ϔ����仗���t�p��mup�$�M�]��i���\��)�ԣ���;���tX�R�᡼�5 �?�����&�k-��sh���\���e�a j(�4�!�f�z�c1�oCy�}���m��������C���T]�"�JVۦA�aK�U1e�pT�����!m����m|o��D�|�LR�|z�a+���<B�!P�{p7� i�'��.�W��n�HWL��Y�@�g<��5c@B���ѠA���G���2��"����������<���\<���YxD�c�o�}T�%�_s�tx�c���_�q�-��u:䥫�K�P��������D$�B82�����Z~}�B�Z��� ��q�Ɓ�|�q���]M�+G^O�Q:!����a��6y/�7v�ۣ}R��m�=n��csU�����w�m{��p�]��E�� !��@H���		�
���
r���@U����Ǜy��G�gW��_U���GU��
���0�(>`)�;��pp��f��`D��,P�(�˚h�	ys����lSCU���m��U貫oohI>�+�SN/��bk?���H>'M02��~Q��d�̌�36W�� �\䠜l��<t��/A�<M�Ǜ��?�г2l� ݓ�>wzG[g|�&�+?{��������/g$?�w%�nb	m~��C�΀>��M�!�j��m���T!���ɉb��@�)���ކv��n�~�0`�6t:E_�{0�̯Ӕ`�C�h
Q'�Ԑ��\�/
�,��[Ʒ�	�l��&��/�ϸxx��v���=�n@(�Cc���o��6�#����<����E-�c �j�j[�srE���ӑ���]ۘB�X�%��sS �!���c�����pt ��|$+s�1>"���m���S���Td��ɴk9���<������
��پm�[c��.N�)4*]}jB-���k�BJ��w��&ݹ��Tu�����:l�%e�-:d*(�.*��|~��]C�5����#��8��C��FG���Ʉ��Rhݪ�2����Wu����&��NM�-_�]�k#�Vt��I�Bodk�)xcsO5����k&ѷ����zh�@ү;���?�E��d�����W�!�v����>�V����?����s���������}b�_=|����!E�6E�&E,�_�y���w����~���gRh�g_�c�DF�JJ���D,���R/��e"�x����� ))���xFN�	������>��_O����O����٣�;������;}e�~+B|?��H�? �^!k���}���@���=����{w�������y�����V��1�j0�=�X�-J�~:�ܷ�b��$̳�Ͱ������Y�Z����D +�+_E V��:��Bm;���
�ူ�؎rSb;!���ȼ����Y{.���Y����V��� ̳K����"��B]�9�i<g��vk>�3i���z����Y��)6!��Gž4,����L�윍	��9�ߝ����v���|sڎf,�n�yӰ7/����7X�&5hW���}~yT\0C�t���&�IX�x��G��*��&;�M]��\�Xk����/s��A��3%_o&!a��=!�YT�z�J�
a��}���Ơ�"��@���C?h��1��7m�ϖ���jq�WkjX�y���B��"}·D����F<9��'Ƣ�z��y|���!�:ͫ���,�7�,�8U��y&�'��Z�����x֔�l{yT��Y>�w��$��M�N�Giz6��ben&G�X9����f#�Z���.{�{�6�~I�}I�|I�{I�zI�yI�xI�wI�vI�uI�tIl�\^�̻ě����&��_�(��}��p���g��%�,�;��-.������Y���В��%�|�]\��B�֮�@��v�'m`�=ܼ�
�s?��N��e59E��Tq�3��~�*�,-�i����B��x#�*D�$GͨpR��s"���d<��N���L�dBE��m�^�������y���to?Kg�@d�\y�<�DM=^� �liSݔ�'�X�vn_�~Jta�T(b��2I��j®�L��s�vK�h�D�*��� ��'�=c�raU�|��XK6;�ʤ[%�H��A�����!w����{��"��[�����G���[��7v^�}��rÿ`o7�s���e7��o��x�u6�e�<����u�OC��|#����}v���+����{���
����z#��_�˲�~��'�~�Q��$�B����?r��?x���<��?�֔��Д�`��y+=����T�֢̥�'I�׽����}~�����F7��k���rv�<�\�m�f:O�r������pLW��T�t�֦>��g�+��#�(-���:�Y9�alɬ�4�Q�1K*WHM��dq�W��Y��$����H��re�va_F����M�١�t�q޶�8m�{���0WT5~\<6��M��tű2i��[m�"�;mFms�;���`<��42�����cAf՚�d qˡ��aU����~�x?��@�8�h�`۹��o�|{����5G��4�p�Fk'�bP=�K��o��TDTNR��IFj$!�k�pд�BTA���Yc{T�ό�~\W�;�Q�ş��./��d�����⁽_�Vi�(P��@��.�y�9�	�R�K�*�:�ח����������/mȹ%}������#�k?aE.&��E��[�����0�w�X?�>>�J����wO�	��m�z0����>��o��rY�-�d��Z��5S�^-U���)N���65�r)�?hi��Xi-s6N0��bu���������W�QZ˞2�l���e�3��p�h�	�9'P�
4m9�r�dk6o�jk8�Z��y5W��T�7�O���GpN'tU"�4��c5�/
\u2���>-��Q�$]U�c�XhĦ<抍ԬH0�o�yG�
�z]�
��b<�/�{�lA�����52}jP�P����%�tqY{�B1�_]�e9��ʑ�ٰ6�h��@e���1�BTbK�u$���]G2�y�N�v	F��ؙ�]��	����t& N�<gRG��P����z��(�b��q�(;�7�z���đ�r�	���\֤{�hz֩5x5�-��1t:�h��	�*Q��l��|L_��3�H/��Qn�Pϣlq(�f�-������hi���#��g�B-��D�]vB@\(���w(L�_�i�R��DM�O��|ܢ;"}r��W�ِ��фB�}8�d�f0vcގL�P�&9�j�H��q}!v:�V�Qa�
w�2�ail�>}c��@\�n�`���E�7������c���w`u��s�Q��Л�Qӣ��e���Ӛh΋�ЎO�+�/�_edNMq1VB��"�4��I����e4��zz{�x��/��>��K�o��JZ�6z�x�y�qPD�ƓŇ�M�4��1��1�5�9��2~��>!�/ ���TZWH��ОpM��֧�/b�,������rN'X4;�?���<��9�,O�T�P"�K|��o��^��E^�tn��Tv�ל�����s��Od�o�şk��E���?ģѯ��������+��%p��wӤ��)�j���ϝ\C�y�ܙ�!)���͗�>$F��a���d�
��L�P��Ή��hW�3tT��n�ww�!A��&�i���;��Wצ�����w���'���0�*At�z^���R��4�u=�ŗ�Y^S�_���Y:��pK%�����"���[�V��uÁ����b	� �\ �?���a����(�� �s��~��L]��3A���`����1�7���q���m#�����.�51���$y�4��T�ɑ}jv��4���ԑ�4�<��_P�Wh5��2`	� �t��d�J|L��'X]T�`�2���Kt�lC���§��=P1�w������y����rn<�L��sER@��j���Y���6��49ׅ���w���m��������\�46���C8j���8X!�"tb��Ɣ��$�2(0�N�QW�����s�$��T��ٝȾܺ#�;����M�o"lo.z������}c��lX؏���z���aS�����"��+Nx��0M|ֳ
�hc|l�t��h>��Ŧb�4�Zc�"ZW�����p�Fb���p,��Fʡ̭5n���"rؼ�p�BR�3����pY���Wۀ��5.�oD�7�c����$��G&p��l]`�Һ[�&�������~��)���w���p�I�r��8�
"$���x�/0���Pπ�;�1`N���0�wo z��N�"��S�?�^�{٬۫.^� ݵ��`�P����dTO�`()=�Cm#
H	��|�.�d�\�VIP�5�&�nn������F)�k��W�1�5����bf�`���m@�ce2�MA��@��qs��B�K�%(�)���XfaA!;���/�+!*t½a;x�	D�^�h@�͒WU\U�`e��"`�n��4)0��Uq�6�lTo�?x��#i/|t���cƽRa�n��*T� �5&k�v����7v%�%�\�!=9��L�r�ºf�q�iH�y�8� V@Yݣ�� �rE��䫇�vh�_�M��6�4M��t��L$]Y���<74�h���N��%p���N(-�D�w1�n�-n�0R,ۘ\��)�t��~�ոp���g��'�f������ް�_�����]���2����HES����Qg���翾��q��F?%4���l�sñ����Ûܕ��3��F�����i�>EWc<+V7���;(�dlp�c����i�bKm���ʅ^����
_M[��?E'���k
:��/V�FeЋ%�R )��D��)�D/��u�J��S=
����g��ԓz�$���
�&��9p,�{���{����^���>��K~�Y'�%��T|iȍ[��C|�9<���XR %@��H<I�@��J� @2�(�H:�Vb@�� %��(�B�$P�`ȧ�s�!�;�ɧ�X3�����/<y���M[�v�{�٩�Qn�(���&[�o!�Fe��>x��V�,W��:ϕ�:]:-U�%�+=�i�^N�7D�L�l�k4�Ep|�����'*�3���v����/ٲvE��tIhTy�Y`��:jt�Յ*ͱ�څWV����TF�3acl�U����I7�jV*��t��ֵ�;�b���I�3s�2���}q�z�Z#{��;𖁈p��M	�ҷ/�l�W,�\>�/�z��V��y��?�r\}c����͗�vE�(�1��:�pʕ�j�/�Ϧ#m~��V��L����� �9Q�pH^������q�եͺ����Z�4�l����eNlU�Gl�3O�N��v�]�gM�"Lu�Wi�pQiP�}mYu��aކH���E��ܳ,��e���V��˸mry�.S�_���9m�پ�W�w�4���4$Bz9�	1O������ر㭝��C�E�	��ګ{w��$���O��/;���}�z׶����y����_��ȱ�ܱ=�_n�����z�����-߿��?������{�2��+׿���(^��(������lۗ�{�%.l�tw�߯��s��;��Β_n��w�>Ҕ�N��χ�]�Qy_�E�^�ۯ�����90� ��_hR�x�q�E��x���>�w>�����'I��?
����!跬?C�4�?
`���Q���$����?��<���  ����4�?���4E>����?���*�������/ç*����/���-���;���π��o��)���%`���;�@�!*�G��G1)�#A��3w�#���%A�IqĄ'0���q@F1��~�o�Qw���?�S���!�7�����_���J��2�,Ws���m�R�;ڔk��QFR޵��0�ۇ�^���ƕ�Y���a�׆{n�21���au��F_t'Sj8�;T����!����SN�I���kj�!�x?�'Ku�.ϵ����v��?�������CaH��p(��-�R��?
���4y'�� �� *��Aa`�_�����x����q� �����L��K���_8�S�m��?`���N�K!d�����p���[���Q /�����D������������	`N'��9�t	绀�����B�`��B��� ����X�?wS����?� ������(��Q��߾����K��VZcQtKټ.�b.���r��y*��34��S�g���I�����a��7�~^Z?���~�y�a,�F臷�}>�}3�������YZ2N��QYD�͸�,���eyw3\��Yc����tgr�U���Zi�S�b�j���j���o����}�Om�į�}V�l�R=�љ���� �:��W,������.g��z����S=n��;͔��'fF$qΝJ���oKɚU�(Ԇ�Fs��Fu0]���}��:ru)��u�w[�l�m븫��{�S�ےX�?8�/�k�(� ����[�a��p�_��p�B,��;�O��F��'���b��;�����t�@�Q���s�?,�������9�����	���?��������?��wtw�3y�Ӎ�=��yw�����+��>�����������㰞x�|�ݮ�k���`�?�s3����,��}�"v�&S�o-��Q�٦�IN�'I��Z������d�T�޲L=�����q},�r~����� Ք���O�΍���1>�t���c|��;�1�섮�h��Hbw?��xzk�x9�̡�U,F��U����<�[��绣Tf�'�WL��^�ȉE�z�8i�3{kh���/�B�Qw��0����f�m����s�?��yv/\����	p��hPB8�($y*�D.`E��$)�ɘ�@C1��y!�� $��9Fb2&aF�������?�N�������DY�˕���*�ۓtX/d����ڴb6IPU��mQ������>��8O��Q]�(u]%�㦷�m{.W�ŒQ�t+hI��Ms�m�}�WQ�.'\R�v�������8����Y
���9��
������?�����a`������8���og�zw��K�e?��y�/�%ޝ5�z��z�4�8]��?���-��&��D�c�ץ�U��̩<&F�3	U���,!;I�X������q�+�Ѯ�u����Ӱݷu�l��n�q��x��4����n��k�' ��/��*���_���_���Wl�4`�B�	�;KB����Ng���_���	�UUُw���<h�>����hZ���I����+�NJ����=3 ���@|�g�� 8Kհڛ�S��R%.C ^� ��ъ���\jf+�qZ-�9�#�]���F=7����q�NU=�t)�:����zT8���V=�wVo�v*Y�r1M�0'Ͼ�����W���]��z�`�%7�s<�U����'!O_10�E�r��$�ت�{���)��c� C�A�qZ�ź��T����JI�,��70��KM��2xx����P6u[5�^�llw�JY�v�S����FM�L�#�h.�?�lz�:����D��R9vV��Qexy�-Vf��g�/��A��r�8�����w���b��?�
|���P�/P��K��m���P��8�?M�9���$@����-P��/��s	�?
��?����?����DA�A@��(�x���dER����c6$}��}�g�X E^�?�.� |��#Q�Y!�|ޏ���ÀC������	~g���
v���v��b�ui��t�'���ٱ��'�2ٕ�ŏ��NG�Do��N��Ҩz�nS���C,��ZO�v�"i}l��c�'e��+�>�;��麴��oU��*�m�d��}-p��)����� �������o	�P����<MC����&�������h1�w��_4���M���9�˗���� ����;-@�^��������ok�Z���1*+��j LV�ln����B�5����ikL���������Q6����<���N��9��I��/�~Wwb��Tuvp�fo���`2l��\�kc���֕ڲ9���y���ܨ��3�p��	�:�D��Ԍ��c�c5��nWi�2[%.g�ڃ��emk���rne������Dl;�Y�Xl�'��ڒj�7't��������NdSwU�Vٴa�'��;�Y�?I\_*��^I�.v�}7�I{5*'F�p~����hUY�k_7rSv1虵�ON�*+	��r;2�e�Ȁ��;�=��[��?��+ �����?/;���������N�7O��@�7�C�7���?迏��<� ����s�?����r���Y \�E����� �G���_����b�������P����]z��EO�}�X������H���$y�3��(�����öP4��������]
�0�(������?u���?`��`Q ����������@���!P�����H ��� �t	ǻ����n�P���?�)�n���s7������C[H�!����������?���?��?迂��C��?��Â����0���`�X��w��@� �� ��b��;��� ��N(�/
�n���?���?�G������������C�?����!��������?
�
`��f�1�V��� ����8�?��^����S�Yd,����!ő(ţ��Pbi&f(�#��<��(�R@	�/�,�	��u��������� |��;F��OC>����9��*U2�/��NH�țM������,�	�%�H��V�?���-O����w�l�������v���tg���
�S�]��U)����ܣ��\esn�FW'�:�/��j�m�1�rYswǦV��"V���T��v7_���p�����8��gs8�-8���,��
��������/�'��_q���_;dL�P�ZݼRZ6�DVj�b�6mG�N��/+T��嵾��n<˜�3�Ne�U����؈&�f�c��vk�H�u���;�)��S=���CU޴7��n1���$�0v�f9m�u΂���c�����_D�`�����xm��P��_����������?������,X���~/������k]���_��R_���n��3���^T����J���߃��H;M��J���}H���Y7��l��%m?�6<�Ԇ� !kKDZ��O�Z�����ͤϓ���7�NҘ�S�tʤ͈I-�8i&��=��V׷R��ʉ[m�O�����t���v+Jn*�{a�$zE9���l/6�h_����[�}O��:e�z���!��5h1N+�X���6���۪Q���4s|��`0���_���šy�F�n'��͙א'��D����ʠ�d6�J�$ӫd]p�x�af��r�	�?o��;������-��g����&���O
4��"�G���߯\�o�
�p��(���'�#�G?�WG7(��(�����%)�p���n�Y�@������P��O�?����3���C���VWU�����ô�{�L��IIJ3��ys������h�������KWy�!㦝��Y�x����_S~�[�~<����9?;ד�3�<{���M%yJ]v.��K���ZB|k[���]%	3���5�j*J~)�s�K�v{aC]�R~�u��5���.m�*9[�j*�����l�Hh�T�).K��*sJ֤,~޸��O�n?!��x���|Е[G��5�w;�ç���yYs%ꗟeMn?���뛻��Z�T��D�%�DQ�m���؛�)�c��.s;���5�+Mc�j[b�f��,˜X5YSty�����*a�v���ו�Ж����\L��Rb$��-�J����_�����>��^�����ya_rZڼ���y�'`�����?8�E4�O82�)���H��/�����/�|(�H�&i~4
��F>#|ȅdH��!Ag�G����������	~g���'#��e;�=	�I�^����Ɵ���!�ۜ1�豧ď���r�[�B�E�\�
�����_��o8��.���}<p�����?��!��2������o��8�H�R��y������?#��n:Q�J�h�Bg�G��&��w���¼�XP���5�wI�o��;�����]R�+rSq�r����Sڏx]��f&�S��U�	;^����ޕ6+�m���
�^ŋ���� �vtu  8�CGG �
"������̛�U����t����"e����{�r��⪏��9=4�5�t]L�捲�b��Ӵu��]��C_���dê9=�\Q��W&���~�a?�θ��	g��X�rر)��I�a"U��X�:��sq����<_��&r܏uf�iݛI>�Ǯ;���1c�����(Fih?t��XG��Y�Zw�ca�n��y�Mn���൦�J!Q]no�hp�{���]Q�G������L�A�O��N�]��XŬD:���+�1S�(W�jK��.XVq�P	�J���Z��Y|�~���������=�����n�EJm{#�X�ƦY>��0��qW�������2����%U-ȷ���Z����~��C�0������w��0�Y ��_Mka��B��?o�����1�_l `:�0Ȋ��p������L��>��>��؟+�,��~{�j	�V7�����������6'_�Z���(���u�Ǻ۱�&
ȇ	"���GB�]��:+�ԩ�O��6�&_��?l�'+�u��B�u��:s�</]�b�/����Z�n�}��,���>g�r^-�Й���`��^�G̥p��L����N-��N�ӳ���7h�"��N��/�X���5���p��t�Bx���`�l|Y�Q���ȷY6n^�}Vߏ�-kM�c��Z�)[b�x�6��L�]���n!7�������U�09�/�l[�7�Y�gH���4���x�ʐ9(W1��Uw���8#�a����J�\�G�ԽS	Ú��ǈߧ�U��#�7�eA��������L�E�����?��+���O�!K��D����m�'C@�w&��O����O�����o��?׀�@!��c�"�?��燌���
�B��7�o�n������o���o����-����_y�%����������?����w������M�?��?���'��3A^����}� �������o�?`����'��/D� ��ϝ��;����Y� ��9!+��s������� ����(�����B�G&�S�AQH������_!��r�� ���!������C�����	������`��_��|!������
��0��
����
���?$���� ������!���;�0��	���cA�΀����_!����� �_�����y��?���������\B�a4���<���8��60 ���?��+�W�������&p���*��T�F���a���.�J�2�j�:I릩��dEXc*4FS�÷����(�W����������7�'IXTj
�k�/5XK`�\[�N;i�&k��Ͽ���'a�����M�]�>�+X];��9�Z��~�`jj�p��?���m���M��Gm��v���e�����]X�K�5�፥Bb��
7�PZ{��Y�Ѹ�I�2����ZU�<�����|��nn*�/�����g~ȫ��60�[����/?��!�'?����|J���[�qQ���/?|���S�6!��A���3Cb�Y�k�L�em�]��G�jo͇���)L��e�;Z��l�Nt]|6r)�#	q��æR�=�iTtt�4�KE�Dju���r�R���$�R`�->T����ע��sB����>���ب#"��r�A��A������i�4`�(�����W�A�e�/��=��G���XQ ���Ufy�H7d�N�����>^b�����ښ�Lr��ېףm,&�\{;��)���Et�ۍ�v�j�eW�fe���iyf���	1s���[��H��0s{ML��F]�����հyz��\iun�fɋ:����_��l���Y����k��D��ן��9��Ǎ�{���Zpt)"��D����mA��������C^i>9�|"�,Ξ�gx8ޗt�}0k�Juk�m]�>g�֑[��H�Y���alr_L���c�NHM�i:���vG�t~x��E�8�Oy���� ٣�������v��QaR�O��x{���;�_�Ȍ�_^����>! �����v��)�����Z�w<8����s��N���d�����"�y��#��?w�'��@�o&(��d�Ȋ����c���d��G�|\B��w�A�e���� �+ �l�W���rCa���������_�?2��?�i�����C����(t�7=uf0���~S�������c��R�Sϵia�m����ڏ�Ð�R���~ _Q�;ks�k�o�Z�{�@���_q�a�ϝq���i�V�u�g��>R�{���\�\��u1Y�7ʎ��N��i�w5C})������<sE�rd_��e�ȷ��^�~�;u��&�]�cQ�aǦT�'e��Ti�ce�x����֞��|}f����_֙�uo&i�����Fƌ!׳.��,���~�Ǳ�4��������~��Q�������kM�B������$3��q
��`�?7��^-�w[<" �l�W�����P$�~	� �����/��3������W��?	�?9!w��q��!��c�B�?������#` �Q����s×��z=�������fÎؑ�IՉұF��������>�ǒu��tw�����Z��G5 ��j ��p'����yM���U���(�le1�ö��;��Ҙ��QD��*^?i�p`�+%t�ب�qw��UM�Z��k ����  i�� b6��5mn�vM��>.��z�ZچD{
��1��(�bX;x�V����Qa��Hñ҈ܡ؃*�V:j�!ah4]����Ě���a�7������e���߇E��n�������������c�?�����j�1MZ��ZU5�L#L
�hR�)�$�Z3(\71��L�����Z�!�4�>|��"����?!�?|��?Ĝ:�W�Z�Ϝ����GxG�W��0�-]�\��<�����ʧ�@�����*����h��֛"�)9�}�����a���C�W�qO���$�����g�i,�����G3X��kQ���?�C���T���(B��_~(�C�Onȝ�_L�����!Q���/?|��ϟ�7S{%j=I��%���5�NW\�vZ��!�s��b'���=�O�n<�����fk����VsJ!~t
j�U&�� F������J+�#�J�Nz>@{�m��x���G�}-�����Q������{���� p�(D�������/����/�����h�|P�GQ�9�K�o��?����Z���S��3Q�����x�y7)�{��R�=�߷�  ׅ ^� ��V�W7�T�_��/+fv���^���-�ZO�SY�}��2щ���`d���R���3����*Z�.ʝ]�۬xn}�T�!���T6n�_t�|�r3�s\�`�tL0���X��6�y� r�`��y"�~�7�jU򢱦T���#�5��(��4%��#����O�b+���z1S6�C}*��r�þ�G��|f�x�i�Z�����%�g&�ٳ��c�����92��lu�B�>Z�z-j�����Pl��XX��xN�ʼ�����{G[m�l�O�����/�?F&���'H�B�g�Kwn^)�gjd�޽t�<}��?�T7aԣ����r�ϋ��;j��soZG.�E��t��`k:�Ŀ�r�� %:a��v����l�u�����u����;�����z��������_6���O�_6&�����\/]w�l)������?}J"�y�Sh������Nџ?������������㡚��pt���+�NF%#���K~�xQI�l�'�U�e���FTzg��H���"�(�� 0�#�N`��68!uy��O?���/K��Ou����;l�v�^�_��~����?���ϒ/�W�Y�����ෟ><��LH!}�/J��ۃ�O�y:���r{��޽_z�L�3V��1�A�q�`c,-#(]�R�-=?!�a��������Rl'��=���&���C;�����(}J��;��m�;���5H?�ۻ��b��������	7�������.$y��^h�r��5z�7� {��:P�|=��_N�n[����QXB���k�ܨ�����+��#��b�����%%-��&�>��w�O����=A�o{|�#��sGusi�>L����矔��W5�*��w���ҕ���'���!�    ����& � 