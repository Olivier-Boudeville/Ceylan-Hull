MOUNT_POINT_1=/mnt/ieeedisk1
MOUNT_POINT_2=/mnt/ieeedisk2
MOUNT_POINT_3=/mnt/ieeedisk3


# Not: umount ${MOUNT_POINT_1} || umount ${MOUNT_POINT_2} || umount ${MOUNT_POINT_3}
# since it would evaluate only the first umount if it worked

umount ${MOUNT_POINT_1}
umount ${MOUNT_POINT_2}
umount ${MOUNT_POINT_3} 


echo "IEEE disk unmounted"
