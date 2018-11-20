//
//  ValidateTextType.swift
//  ValidateTextType_tryal
//
//  Created by Yuuichi Watanabe on 2018/11/19.
//  Copyright © 2018 Yuuichi Watanabe. All rights reserved.
//

import UIKit



/// 入力文字をチェックするタイプ (優先してチェックしたいものを先頭に記載)
enum ValidateTextType {
	/// ハイフンを許容する(差し引いて考える) // 正規表現でトリムがあるから、、
	/// 半角スペースを許容する
	/// 空でない
	case inputRequired  // notEmpty
    /// 数字のみである
    case number
    /// アルファベットのみである
    case alphabet
    /// 半角英数
    case halfSizeAlphabetAndNumber
    /// メールアドレス
    case eMailAddress
    /// 電話番号
    /// 郵便番号
    /// ひらがなのみ
    case hiragana
    /// カタカナのみ
    case katakana
    /// 漢字のみ
    case kanji
    /// 日本語以外を含まない
    case japaneaseStrig
    /// 特殊文字を含まない
    case notContainSpecialCharacter


    enum ValidationType {
        /// 一致するかどうか
        case verifyMatch
        /// 不一致なものがあるかどうか
        case verifyMismatch
    }


	fileprivate func getPattern() -> String {						// ^: 先頭, $: 行末, [xxxx]: xxxxのいずれか1文字
        switch self {
		case .inputRequired:					return "\\S" // \\S: 空白以外の全ての文字  // "^$" // ^$: 空以外(空白文字違う0バイト)
        case .number:							return "[^0-9]"
        case .alphabet:							return "[^A-Za-z]"
        case .halfSizeAlphabetAndNumber:		return "[^A-Za-z0-9]"
        case .eMailAddress:				        return "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\\.[a-zA-Z0-9-]+)*$"	//
        case .hiragana:   						return "[^ぁ-ゞ]" // ぁ-ゞ ? ぁ-ん
        case .katakana:   						return "[^ァ-ヾ]" // ァ-ヾ ? ァ-ヶ ?
        case .kanji:                            return "[^亜-熙纊-黑]"
        case .japaneaseStrig:					return "[^ぁ-ゞァ-ヾ亜-熙纊-黑]"	    // [^xxxx] いずれか1文字以外 // "[\\p{Han}\\p{Hiragana}\\p{Katakana}]+"
        case .notContainSpecialCharacter:		return "[^#?!.,:;{}=+@$%&*()~^`_¥/\"-]"
        }
    }

    /// 検索方法の判別(一致するか or 不一致なものがあるか)
    fileprivate func getValidationType() -> ValidationType {
        switch self {
        case .inputRequired:                    return .verifyMatch
        case .number:                           return .verifyMismatch
        case .alphabet:                         return .verifyMismatch
        case .halfSizeAlphabetAndNumber:        return .verifyMismatch
        case .eMailAddress:                     return .verifyMatch
        case .hiragana:                         return .verifyMismatch
        case .katakana:                         return .verifyMismatch
        case .kanji:                            return .verifyMismatch
        case .japaneaseStrig:                   return .verifyMismatch
        case .notContainSpecialCharacter:       return .verifyMismatch
        }
    }
	
	/// (引数で、項目名を足したそのまま出力できるStringとしても使えるようにしたい)
	fileprivate func getDescription(targetName: String?) -> String {
		var header = ""
		if let targetName = targetName {
			header = targetName + "は、"
		}
		switch self {
		case .inputRequired:				return header + "入力必須です。" //
		case .number:						return header + "半角数字以外の文字は入力できません。"//
		case .alphabet:						return header + "半角英字以外の文字は入力できません。" //
		case .halfSizeAlphabetAndNumber:	return header + "半角英数以外の文字は入力できません。" //
        case .eMailAddress:					return header + "半角英数@半角英数.半角英数のフォーマットで入力されていません。(#や%など一部の文字は使えません)" //
		case .hiragana:						return header + "ひらがなのみで入力してください。" //
		case .katakana:						return header + "カタカナのみで入力してください。" //
        case .kanji:                        return header + "漢字のみで入力してください。"
		case .japaneaseStrig:				return header + "ひらがなとカタカナと漢字のみで入力ください。" //
		case .notContainSpecialCharacter:	return header + "#,?,!,~などの文字は入力できません。"//
		}
	}
	
    /// ...であるか？ (該当するか もしくは 該当しないものがあるか (タイプによって判定が違います))
    static func judege(target: String, type: ValidateTextType) -> Bool {
		let pattern      = type.getPattern()
		let targetString = NSMutableString(string: target)

		guard let regular = try? NSRegularExpression(pattern: pattern) else { return false }

		let matches = regular.matches(in: targetString as String, options: [],
									  range: NSMakeRange(0, targetString.length))
        var result: Bool
        if 0 < matches.count {
            //for (i,_) in matches.enumerated() {
            //    print("// hit String = ", targetString.substring(with: matches[i].range)) // < for debug.
            //}
            result = (type.getValidationType() == .verifyMatch) ? true : false
        }
        else {
            result = (type.getValidationType() == .verifyMatch) ? false : true
        }
        return result
    }
	
	/// ...であるか？(複数条件)、でないとすれば何か？	(失敗時の振る舞いにつながるように(メッセージ出せるように))
	/// このメソッドのネーミングセンスどうなんだろう、、とりあえず仮で
	static func catchWithVerify(target: String, types: [ValidateTextType]) -> ValidateTextType? {
		let sortedTypes = types.sorted(by: { $0.hashValue > $1.hashValue })
		for (_,type) in sortedTypes.enumerated() {
			if self.judege(target: target, type: type) {
				continue
			}
			else {
				return type // fail and catched reason.
			}
		}
		return nil	// sccessed.
	}
	
	/// ...であるか？(複数条件を受け付ける)
	static func judge(target: String, types: [ValidateTextType]) -> Bool {
        return (self.catchWithVerify(target: target, types: types) != nil) ? true : false
	}

    /// でない時の文言
}
