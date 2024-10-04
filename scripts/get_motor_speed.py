#! /usr/bin/env python3

from gazebo_msgs.srv import GetModelState
from std_msgs.msg import Float32
import rospy

def publish_motor():
    rospy.init_node('pub_motors', anonymous=True)
    
    pub_motor0 = rospy.Publisher('/motor_speed/0', Float32, queue_size=10)
    pub_motor1 = rospy.Publisher('/motor_speed/1', Float32, queue_size=10)
    pub_motor2 = rospy.Publisher('/motor_speed/2', Float32, queue_size=10)
    pub_motor3 = rospy.Publisher('/motor_speed/3', Float32, queue_size=10)

    model_coordinates = rospy.ServiceProxy('/gazebo/get_model_state', GetModelState)
    blockName = str("halfinho")

    rate = rospy.Rate(30)
    
    while not rospy.is_shutdown():
        resp_coordinates = [0, 0, 0, 0]
        resp_coordinates[0] = model_coordinates(blockName, "rotor_0")
        resp_coordinates[1] = model_coordinates(blockName, "rotor_1")
        resp_coordinates[2] = model_coordinates(blockName, "rotor_2")
        resp_coordinates[3] = model_coordinates(blockName, "rotor_3")

        msg_motor0 = Float32()
        msg_motor1 = Float32()
        msg_motor2 = Float32()
        msg_motor3 = Float32()

        """
        Measure is in rad/s
        1 rad/s = 9.5493 RPM
        velocityslowdownsim = 10
        """

        # Queremos apenas velocidade positiva
        msg_motor0.data = -round(resp_coordinates[0].twist.angular.z * 9.5493 * 10, 2)
        msg_motor1.data = -round(resp_coordinates[1].twist.angular.z * 9.5493 * 10, 2)
        msg_motor2.data = round(resp_coordinates[2].twist.angular.z * 9.5493 * 10, 2)
        msg_motor3.data = round(resp_coordinates[3].twist.angular.z * 9.5493 * 10, 2)
        
        pub_motor0.publish(msg_motor0)
        pub_motor1.publish(msg_motor1)
        pub_motor2.publish(msg_motor2)
        pub_motor3.publish(msg_motor3)

        rate.sleep()

if __name__ == '__main__':
    try:
        print("Publishing Motor RPM at 30 Hz")
        publish_motor()
        rospy.spin()
    except rospy.ROSInterruptException:
        pass
