include Java

import javax.swing.JFrame
import javax.swing.JLabel
import javax.swing.JButton
import javax.swing.JOptionPane
import java.awt.FlowLayout

frame = JFrame.new('JRuby からSwingを使う')
frame.set_size(300, 300)
frame.layout = FlowLayout.new

button = JButton.new('押してね')
button.add_action_listener do |e|
  JOptionPane.show_message_dialog(frame,
    'Hello!', 'JRuby Sample Dialog',
    JOptionPane::INFORMATION_MESSAGE)
end

frame.add(JLabel.new('Enjoy JRuby!'))
frame.add(button)

frame.default_close_operation = JFrame::EXIT_ON_CLOSE
frame.visible = true
