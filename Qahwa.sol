// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * QAHWA — عملة ميم على نمط ERC-20
 *
 * خصائص مقصودة تجعل العقد "نظيفًا" وقابلًا للفحص من أي مشترٍ:
 *   - عرض ثابت 1,000,000,000 (مليار) ولا توجد أي دالة لسك عملات جديدة.
 *   - لا يوجد مالك (owner) ولا صلاحيات إدارية بعد النشر.
 *   - لا توجد رسوم شراء أو بيع، ولا قائمة حظر، ولا إيقاف للتحويلات.
 *   - لا توجد دالة burn إدارية؛ الحرق يتم بإرسال العملات إلى عنوان الصفر المعروف.
 *
 * ما لا يفعله هذا العقد: لا يمنع المطور من بيع حصته، ولا يحمي المشتري من
 * انهيار السعر. الحماية الحقيقية تأتي من قفل السيولة، وتوزيع الملكية،
 * والشفافية، لا من الكود وحده.
 *
 * تحذير: هذا كود تعليمي مبسّط. راجعه بنفسك أو عبر مدقق مستقل قبل استخدام
 * أموال حقيقية. النشر على الشبكة لا يمكن التراجع عنه.
 */
contract Qahwa {
    string public constant name = "Qahwa";
    string public constant symbol = "QAHWA";
    uint8 public constant decimals = 18;

    /// 1,000,000,000 عملة، لا يمكن تغيير هذا الرقم بعد النشر.
    uint256 public constant totalSupply = 1_000_000_000 * 10**18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // كل العرض يُسك مرة واحدة ويُرسل إلى المحفظة التي تنشر العقد.
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= value, "ERC20: allowance too low");

        // allowance غير محدود لا يُخفَّض، وهو السلوك المتوقع لدى المنصات.
        if (allowed != type(uint256).max) {
            allowance[from][msg.sender] = allowed - value;
        }

        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "ERC20: transfer to zero address");

        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= value, "ERC20: balance too low");

        unchecked {
            balanceOf[from] = fromBalance - value;
            // المجموع الكلي ثابت، لذا لا يمكن أن يتجاوز الجمع حدود uint256.
            balanceOf[to] += value;
        }

        emit Transfer(from, to, value);
    }
}
