function scrollToBottom() {
    var chatBox = document.getElementById('chatBox');
    chatBox.scrollTop = chatBox.scrollHeight;
}

window.onload = scrollToBottom;

document.querySelector('form').addEventListener('submit', function(e) {
    var input = document.getElementById('userInput');
    if (!input.value.trim()) {
        e.preventDefault();
        alert('请输入问题内容');
        return;
    }
    setTimeout(scrollToBottom, 100);
});